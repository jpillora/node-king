upnode = require "upnode"
dnode = require "dnode"
Server = require "../common/server"

class ServantServer extends Server

  name: "ServantServer"

  constructor: (@host) ->
    
    if m = @host.match /:(\d+)$/
      @port = parseInt m[1], 10
      @host.replace m[0], ''
    else
      @port = 5464

    @log "connecting to: #{@host}:#{@port}..."

    upnode.connect @port, @host, (remote, conn) =>

      @log "connected to", Object.keys remote
      @log "connection:", Object.keys conn

      d = upnode
        bar: (z, done) ->
          done z + 3

      conn.pipe(d).pipe(conn)


#called via cli
exports.start = (host) ->
  new ServantServer host
