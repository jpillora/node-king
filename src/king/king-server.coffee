upnode = require "upnode"
Server = require "../common/server"
ServantClient = require "./servant-client"

class KingServer extends Server

  name: "KingServer"

  constructor: (@port) ->
    @log "listening on: #{@port}..."

    @servants = {}
    $ = @

    @server = upnode (client, conn) ->
      @join = (host)   -> new ServantClient host, $
      @foo = (n, done) -> done n + 42

    @server.listen @port



#called via cli
exports.start = (port = 5464) ->
  new KingServer port
