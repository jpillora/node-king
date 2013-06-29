upnode = require "upnode"
Server = require "../common/server"
ServantClient = require "./servant-client"

class KingServer extends Server

  name: "KingServer"

  constructor: (@port) ->
    @log "listening on: #{@port}..."

    @servants = {}
    $ = @

    @comms = upnode (client, conn) ->
      @serve = (host)  -> new ServantClient host, $
      @foo = (n, done) -> done n + 42

    @comms.listen @port



#called via cli
exports.start = (port = 5464) ->
  new KingServer port
