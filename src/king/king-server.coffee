#core
http = require "http"
path = require "path"
#vendor
pushover = require "pushover"
upnode = require "upnode"
shoe = require "shoe"
ecstatic = require "ecstatic"
#local
Base = require "../common/base"
dirs = require "../common/dirs"
List = require "../common/list"
ServantClient = require "./servant-client"
WebUser = require "./web-user"
#vars
kingPort = 5464
webPort = 5474
gitPort = 5484

class KingServer extends Base

  name: "KingServer"

  constructor: (@port) ->

    @servants = new List
    @users = new List

    @initStatsd()
    @initGit()
    @initComms()
    @initWeb()

  initComms: ->
    comms = upnode((remote, d) =>
      #for each new connection
      servant = new ServantClient @, d

      #return interface
      return servant.api
    ).listen @port, =>
      @log "comms listening on: #{@port}"

  initWeb: ->
    opts =
      root: path.join dirs.root, 'webui'
      cache: 0

    webs = http.createServer(ecstatic opts).listen webPort, =>
      @log "webs listening on: #{webPort}"

    sock = shoe((stream) =>
      #for each new connection
      new WebUser @, stream

    ).install webs, "/webs"

    @servants.on 'add', (item)    =>
      @userBroadcast 'servants-add', item.serialize()

    @servants.on 'remove', (item) =>
      @userBroadcast 'servants-remove', item.serialize()
  
  userBroadcast: ->
    args = arguments
    @users.each (user) =>
      user.remote.broadcast.apply null, args

  initGit: ->
    @repos = pushover path.join dirs.king, 'repos'

    server = http.createServer((req, res) =>
      @repos.handle req, res
    ).listen gitPort, =>
      @log "git listening on: #{gitPort}"

    @repos.on 'push', (push) =>
      @log('GIT: push')
      push.accept()
  
    @repos.on 'fetch', (fetch) =>
      @log('GIT: fetch')
      fetch.accept()

    @repos.on 'tag', (tag) =>
      @log('GIT: tag')
      tag.accept()

    @repos.list (err, rs) =>
      @log "GIT: list: ", rs

  initStatsd: ->
    @log('init statsd')


#called via cli
exports.start = (port = 5464) ->
  new KingServer port
