#core
{spawn,fork} = require "child_process"
#vendor
upnode = require "upnode"
#local
Base = require "../common/base"
List = require "../common/list"
helper = require "../common/helper"
capabilities = require "./capabilities"

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

    #create api
    @api = @makeApi()

    #create upnode client
    @comms = upnode @api

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

  #exposed api
  makeApi: ->

    id: @id
    capabilities: @capabilities

    exec: (cmd, callback) =>

      @log "executing: '#{cmd}'"

      args = cmd.split /\s+/
      program = args.shift()

      proc = if program is 'node'
        fork args
      else
        spawn program, args

      @procs.add proc

      proc.stdout.on 'data', (buff) =>
        # @log "process (#{proc.pid}): STDOUT: #{buff}"
        callback { type: 'stdout', msg: buff.toString() }

      proc.stderr.on 'data', (buff) =>
        callback { type: 'stderr', msg: buff.toString() }

      proc.on 'close', (code) =>
        callback { type: 'close', code }
        @procs.remove proc

      proc.on 'error', (err) =>
        callback { type: 'error', err:err.toString() }
        @procs.remove proc

      null

#called via cli
exports.start = (kingHost) ->
  new ServantServer kingHost
