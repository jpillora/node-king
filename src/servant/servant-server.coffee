
#vendor
upnode = require "upnode"
#local
Base = require "../common/base"
Database = require "../common/database"
List = require "../common/list"
helper = require "../common/helper"
proxy = require "../common/proxy"
capabilities = require "./capabilities"
ServantProcess = require "./servant-process"

class ServantServer extends Base

  name: "ServantServer"

  constructor: (kingHost) ->

    #instance variables
    @kingAddr = helper.host.parse kingHost
    @id = helper.guid()

    @watchers = new List
    @procs = new List
    @status = 'down'

    #bind all methods
    helper.bindAll @

    #init db
    Database.init { displayId: @id }, @gotDb

  gotDb: (err, @db) ->
    @err "db error: #{err}" if err

    #pass db changes through to watchers via king
    @db.change (type, args) =>
      a = Array::slice.call args
      a[0] = "servants.#{@id}.#{a[0]}"
      @watchers.each (id) =>
        path = "king.users.#{id}.remote.proxy.store.#{type}"
        @remote.proxy.apply @remote, [path].concat a

    #running processes
    @db.status 'procs.running', 0
    @procs.on 'add', =>
      @db.status 'procs.running', @procs.length
    @procs.on 'remove', =>
      @db.status 'procs.running', @procs.length

    #get stored display id
    @db.get 'displayId', @gotDisplayId

  gotDisplayId: (err, @displayId) ->
    @err "id missing..." if err
    #get capabilties
    capabilities.calculate @gotCapabilties

  gotCapabilties: (capabilities) ->

    #create upnode client with api
    @comms = upnode
      id: @id
      displayId: @displayId
      capabilities: capabilities
      proxy: proxy @

    #connect to king comms
    @log "connecting to: #{@kingAddr.host}:#{@kingAddr.port}..."
    @d = @comms.connect @kingAddr.port, @kingAddr.host
    @d.on 'remote', @onRemote
    @d.on 'error', @onError

    @d.on 'up',        => @setStatus 'up'
    @d.on 'down',      => @setStatus 'down'
    @d.on 'reconnect', => @setStatus 'connecting'

  #event listeners
  onRemote: (remote, dnode) ->
    dnode.on 'error', @err

    @log "connected to server"
    @remote = remote

  onError: (e) ->
    @log "connection error!", e

  setStatus: (s) ->
    @log "status #{@status} -> #{s}" if s isnt @status
    @status = s

  exec: (cmd, cb) =>
    try
      id = ServantProcess.run @, cmd
      cb null, id
    catch e
      @log "Process Exception: #{e}"
      return false
    true

#called via cli
exports.start = (kingHost) ->
  new ServantServer kingHost
