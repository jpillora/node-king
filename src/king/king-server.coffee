#core
http = require "http"
path = require "path"
#vendor
upnode = require "upnode"
shoe = require "shoe"
ecstatic = require "ecstatic"
#local
Base = require "../common/base"
List = require "../common/list"
ServantClient = require "./servant-client"
WebUser = require "./web-user"

rootdir = path.join __dirname, '..', '..'

class KingServer extends Base

  name: "KingServer"

  constructor: (@port) ->
    
    @servants = new List
    @users = new List

    @initComms()
    @initWeb()
    # @initGit()
    # @initStatsd()

  initComms: ->
    comms = upnode((remote, d) =>
      #for each new connection
      servant = new ServantClient @, d

      @servants.add servant
      d.on 'end', =>
        #for each ended connection
        @servants.remove servant
        servant.dismiss()

      #return interface
      servant.api
    ).listen @port, =>
      @log "comms listening on: #{@port}"

  initWeb: ->
    opts =
      root: path.join rootdir, 'webui'
      cache: 0

    webs = http.createServer(ecstatic opts).listen 8080, =>
      @log "webs listening on: 8080"

    sock = shoe((stream) =>
      #for each new connection
      user = new WebUser @, stream

      @users.add user

      stream.on "end", =>
        console.log("web client end!")
        @log "web client end"
        @users.remove user

    ).install webs, "/webs"

#called via cli
exports.start = (port = 5464) ->
  new KingServer port
