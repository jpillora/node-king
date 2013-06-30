upnode = require "upnode"
Base = require "../common/base"
helper = require "../common/helper"

class ServantServer extends Base

  name: "ServantServer"

  constructor: (kingHost) ->

    #king address
    king = helper.host.parse kingHost

    #create api
    @api = @makeApi()
    @id = @api.id = helper.guid()

    #bind all methods
    helper.bindAll @

    #create upnode client
    @comms = upnode @api

    #connect to king comms
    @log "connecting to: #{king.host}:#{king.port}..."
    @d = @comms.connect king.port, king.host

    @d.on 'remote', (r) =>
      @remote = r
      @log "got server remote:", Object.keys r
      @remote.report "#{@id} at your service..."

    @d.on 'error', @failure
    @d.on 'end', @astray

  failure: (e) ->
    @log "connection error!", e

  astray: ->
    @log "gone astray!"

  makeApi: ->
    bow: (name) =>
      @log "#{@id} bows down..."


#called via cli
exports.start = (kingHost) ->
  new ServantServer kingHost
