upnode = require "upnode"
Server = require "../common/server"

class KingServer extends Server

  name: "KingServer"

  constructor: (@port) ->
    @log "listening on: #{@port}..."

    $ = @

    @server = upnode (client, conn) ->
      
      conn.on 'remote', (remote) ->
        $.log "remote connected", Object.keys remote 

      @foo = (n, done) ->
        done n + 42

    @server.listen @port


#called via cli
exports.start = (port = 5464) ->
  new KingServer port
