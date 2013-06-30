Base = require "../common/base"
helper = require "../common/helper"
upnode = require "upnode"

# servant client
# 1. recieves api from a given servant
# 2. exposes api to servants

module.exports = class ServantClient extends Base

  name: 'ServantClient'

  constructor: (@king, @d) ->
    @id = "..."
    @remote = null

    @api = @makeApi()

    @d.on 'remote', (remote) =>
      @id = remote.id
      @log "setting remote:", Object.keys remote
      @remote = remote

  makeApi: ->
    report: =>
      @log "data reported", Array::slice.call arguments
    
    config:
      get: =>
        @log "get..."
      get: =>
        @log "set..."

  dismiss: ->
    @log "dismissed..."



