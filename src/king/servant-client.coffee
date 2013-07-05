Base = require "../common/base"
helper = require "../common/helper"
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
    
    @api = @makeApi()

    # helper.tap @d, 'emit', @log

    @d.on 'remote', @onRemote
    @d.on 'end',    @onEnd

  onRemote: (remote) ->
    @id = remote.id
    @log "connected"
    @remote = remote

    #add self
    @king.servants.add @

  onEnd: ->
    @log "dismissed..."
    @king.servants.remove @

  serialize: ->
    id: @id
    capabilities: @remote?.capabilities

  makeApi: ->
    broadcast: =>
      @king.broadcast.apply @king, arguments


