Base = require "../common/base"
helper = require "../common/helper"
dnode = require "dnode"

# web user - used by king to
# communicate with web users

# exposes api to allow web users to
# communicate back to king

module.exports = class WebUser extends Base

  name: 'WebUser'

  constructor: (@king, @stream) ->
    @id = "..."
    @remote = null

    @api = @makeApi()

    @d = dnode @api

    @d.on "remote", (remote) =>
      @log "got remote", remote
      @id = remote.id
      @remote = remote

    @d.pipe(@stream).pipe @d

  makeApi: ->
    hi: (n, cb) =>
      @log "hi!"
      cb n + 42
    config:
      get: (k,cb)   =>
        @log "get #{k}"
      set: (k,v,cb) => 
        @log "set #{k} = #{v}"

  dismiss: ->
    @log "dismissed..."



