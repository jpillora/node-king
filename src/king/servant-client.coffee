Base = require "../common/base"
helper = require "../common/helper"
proxy = require "../common/proxy"
upnode = require "upnode"

# servant client
# 1. recieves api from a given servant
# 2. exposes king api to servants

module.exports = class ServantClient extends Base

  name: 'ServantClient'

  constructor: (@king, @d) ->
    #variables
    @id = "..."
    @remote = null

    helper.bindAll @

    @d.on 'remote', @onRemote
    @d.on 'end',    @onEnd

  onRemote: (remote) ->
    @remote = remote
    @id = remote.id

    #add self
    @king.servants.add @
    @log "connected"

    @king.users.proxyAll 'servants.add', @serialize()

  onEnd: ->
    @king.servants.remove @
    @log "disconnected"

    @king.users.proxyAll 'servants.remove', @serialize()

  serialize: ->
    id: @remote.id
    guid: @remote.guid
    capabilities: @remote?.capabilities


