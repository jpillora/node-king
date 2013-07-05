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

    servants = @king.servants.map (s) -> s.serialize()
    @remote.broadcast 'servants-init', servants
      
    @king.users.add @

  onRemote: (remote) ->
    #user has provided server with api
    @remote = remote
    @id = remote.id

  onClose: ->
    @log "disconnected"
    @king.users.remove @

  makeApi: ->

    servant: =>
      args = Array::slice.call arguments
      callback = args[args.length - 1]
      callback = @log if typeof callback isnt 'function'
      id = args.shift()
      servant = @king.servants.get id
      unless servant
        return callback "missing servant: '#{id}'"
      servant.proxy args

    king: => @king.proxy arguments



