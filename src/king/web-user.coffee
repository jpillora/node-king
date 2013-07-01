Base = require "../common/base"
helper = require "../common/helper"
dnode = require "dnode"

# web user
# 1. recieves api from a given web user
# 2. exposes king api to web users

module.exports = class WebUser extends Base

  name: 'WebUser'

  constructor: (@king, @stream) ->
    #variables
    @id = "..."
    @remote = null

    helper.bindAll @

    #connect to user
    @api = @makeApi()
    @d = dnode @api
    
    @d.on "ready", @onReady
    @d.on "remote", @onRemote

    @d.pipe(@stream).pipe @d

    #hack: stream emit not landing...
    helper.tap @stream, 'emit', (e) =>
      @onClose() if e is 'close'

  onReady: ->
    @log "connected"

    @remote.broadcast 'servants-init',
      @king.servants.map (s) ->
        s.serialize()

    @king.users.add @

  onRemote: (remote) ->
    #user has provided server with api
    @id = remote.id
    @remote = remote

  onClose: ->
    @log "disconnected"
    @king.users.remove @

  makeApi: ->
    hi: (n, cb) =>
      @log "hi!"
      cb n + 42

    exec: (index, cmd, callback) =>

      servant = @king.servants.get index
      unless servant
        return callback {type: 'error', msg: "missing servant: #{index}"}

      @log "executing: '#{cmd}'"

      servant.remote.exec cmd, callback

    config:
      get: (k,cb)   =>
        @log "get #{k}"
      set: (k,v,cb) => 
        @log "set #{k} = #{v}"




