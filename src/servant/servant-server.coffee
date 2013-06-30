upnode = require "upnode"
Base = require "../common/base"
helper = require "../common/helper"

class ServantServer extends Base

  name: "ServantServer"

  constructor: (kingHost) ->

    helper.bindAll @

    #connect to king comms
    king = helper.host.parse kingHost
    @id = helper.guid()

    @comms = upnode
      id: @id,
      hi: => @log "hi"

    @log "connecting to: #{king.host}:#{king.port}..."
    @d = @comms.connect king.port, king.host

    @d.on 'remote', (r) =>
      @remote = r
      @log "got server remote:", Object.keys r

    @d.on 'error', @failure
    @d.on 'end', @astray

  failure: (e) ->
    @log "connection error!", e

  astray: ->
    @log "gone astray!"

#called via cli
exports.start = (kingHost) ->
  new ServantServer kingHost
