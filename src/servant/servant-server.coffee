upnode = require "upnode"
dnode = require "dnode"
Server = require "../common/server"
ip = require "../common/ip"

class ServantServer extends Server

  name: "ServantServer"

  constructor: (kingHost) ->

    @log "retrieving king interface on #{@host}:#{@port}..."

    @port = 13000

    @server = upnode (client, conn) ->

      @bar = (n, done) -> done n + 42

    @server.listen @port

    king = ip.host kingHost
    upnode.connect king.port, king.host, (remote, conn) =>
      @log "connected to king."
      #now, become one of king's servants
      remote.join "#{ip.address()}:#{@port}"

#called via cli
exports.start = (host) ->
  new ServantServer host
