Base = require "../common/base"
proxy = require "../common/proxy"
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
    @d = dnode {proxy:proxy @}
    
    @d.on "ready", @onReady
    @d.on "remote", @onRemote

    @d.pipe(@stream).pipe @d

    #hack: stream.on close not firing...
    helper.tap @stream, 'emit', (e) =>
      @onClose() if e is 'close'

  onRemote: (remote) ->
    #user has provided server with api
    @remote = remote
    @id = remote.id

  onReady: ->
    @log "connected"
    @emit "connected"
  
  onClose: ->
    @log "disconnected"
    @emit "disconnected"



