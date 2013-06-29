upnode = require "upnode"
Server = require "../common/server"
ip = require "../common/ip"

class ServantServer extends Server

  name: "ServantServer"

  constructor: (kingHost) ->

    @port = 5000 + Math.floor(Math.random()*60*1000)

    #connect to king comms
    king = ip.host kingHost
    @log "retrieving king interface on #{king.host}:#{king.port}..."
    upnode.connect king.port, king.host, (remote, conn) =>
      @log "connected to king."
      #now, become one of king's servants
      remote.serve "#{ip.address()}:#{@port}"

    #create comms server
    @comms = upnode (client, conn) ->

      @bar = (n, done) -> done n + 42

    @comms.listen @port

#called via cli
exports.start = (kingHost) ->
  new ServantServer kingHost
