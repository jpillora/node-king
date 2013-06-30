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

    @d.on 'remote', @newRemote
    @d.on 'end',    @destroy

  newRemote: (remote) ->
    @id = remote.id
    @log "connected"
    @remote = remote

    #add self
    @king.servants.add @

  serialize: ->
    id: @id
    capabilities: @remote?.capabilities

  makeApi: ->
    report: =>
      @log "data reported", Array::slice.call arguments
    
    config:
      get: =>
        @log "get..."

  destroy: ->
    @log "dismissed..."
    @king.servants.remove @



