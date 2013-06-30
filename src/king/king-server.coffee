#core
http = require "http"
path = require "path"
#vendor
upnode = require "upnode"
dnode = require "dnode"
shoe = require "shoe"
ecstatic = require "ecstatic"
#local
Base = require "../common/base"
ServantClient = require "./servant-client"

rootdir = path.join __dirname, '..', '..'

class KingServer extends Base

  name: "KingServer"

  constructor: (@port) ->
    
    @servants = []

    @initComms()
    @initWeb()
    # @initGit()
    # @initStatsd()

  initComms: ->
    @comms = upnode((remote, d) =>
      #for each new connection
      servant = new ServantClient @, d

      @servants.push servant
      d.on 'end', =>
        #for each ended connection
        @servants.splice @servants.indexOf(servant), 1
        servant.dismiss()

      #return interface
      servant.getInterface()
    ).listen @port, =>
      @log "comms listening on: #{@port}"

  initWeb: ->
    opts =
      root: path.join rootdir, 'webui'
      cache: 0

    @webs = http.createServer(ecstatic opts).listen 8080, =>
      @log "webs listening on: 8080"

    sock = shoe((stream) =>
      d = dnode(
        hi: (n, cb) =>
          @log "webs hi"
          cb n + 42
      )

      d.on "remote", (remote) =>
        @log "web client remote", remote

      stream.on "end", => @log "web client end"
      stream.on "error", => @log "web client error"
      stream.on "fail", => @log "web client fail"
      stream.on "close", => @log "web client close"

      d.pipe(stream).pipe d
    )

    sock.install @webs, "/webs"
#called via cli
exports.start = (port = 5464) ->
  new KingServer port
