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

  onRemote: (remote, dnode) ->

    dnode.on 'error', @err
    @remote = remote
    @id = remote.id

    #add self
    @log "connected"
    @emit 'connected'

  onEnd: ->
    @log "disconnected"
    @emit 'disconnected'

  serialize: ->
    id: @remote.id
    displayId: @remote.displayId
    capabilities: @remote?.capabilities

  destroy: ->
    @d.end()

