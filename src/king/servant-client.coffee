Base = require "../common/base"
helper = require "../common/helper"
upnode = require "upnode"

module.exports = class ServantClient extends Base

  name: 'ServantClient'

  constructor: (@king, @d) ->
    @id = "..."
    @remote = null

    @d.on 'remote', (remote) =>
      @id = remote.id
      @log "setting remote:", Object.keys remote
      @remote = remote

  getInterface: ->
    id: @id
    hi: => @log "hi"

  dismiss: ->
    @log "dismissed..."



