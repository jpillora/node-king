
#vendor
upnode = require "upnode"
#local
Base = require "../common/base"
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
    @procs = new List
    @status = 'idle'

    #bind all methods
    helper.bindAll @

    #get capabilties
    capabilities.calculate @gotCapabilties

  gotCapabilties: (@capabilities) ->

    #create upnode client with api
    @comms = upnode
      id: @id
      capabilities: @capabilities
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
  onRemote: (remote) ->
    @log "connected to server"
    @remote = remote

  onError: (e) ->
    @log "connection error!", e

  setStatus: (s) ->
    @log "status #{@status} -> #{s}" if s isnt @status
    @status = s

  exec: (cmd) =>
    try
      new ServantProcess @, cmd
    catch e
      @log "Process Exception: #{e}"

#called via cli
exports.start = (kingHost) ->
  new ServantServer kingHost
