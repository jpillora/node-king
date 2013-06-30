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
    @d.on "remote", @newRemote
    @d.pipe(@stream).pipe @d

    @d.on "end", @destroy

  newRemote: (remote) =>

    #user has provided server with api
    @id = remote.id
    @log "got remote", remote
    @remote = remote

    @remote.broadcast 'servants-init', @king.servants.map (s) -> s.serialize()

    @king.users.add @

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

  destroy: ->
    @log "web client lost..."
    @king.users.remove @



