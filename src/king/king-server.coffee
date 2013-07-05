#core
http = require "http"
path = require "path"
#vendor
pushover = require "pushover"
upnode = require "upnode"
shoe = require "shoe"
ecstatic = require "ecstatic"
#local
dbs = require "../common/dbs"
Base = require "../common/base"
helper = require "../common/helper"
proxy = require "../common/proxy"
dirs = require "../common/dirs"
List = require "../common/list"
ServantClient = require "./servant-client"
WebUser = require "./web-user"

class KingServer extends Base

  name: "KingServer"

  constructor: (@webPort = 5480) ->

    helper.bindAll @
    @servants = new List
    @users = new List

    @log "init dbs..."
    dbs.init @gotDBs

  gotDBs: (err, @config, @status) ->
    return "config error: #{err}" if err

    @startWeb(@webPort)
    @startStatsd()
    @startGit()
    @startComms()

  startWeb: (port) ->
    opts =
      root: path.join dirs.root, 'webui'
      cache: 0

    webs = http.createServer(ecstatic opts).listen port, =>
      @log "webs listening on: #{port}"
      @config.put 'port.web', port

    sock = shoe((stream) =>
      #for each new connection
      new WebUser @, stream

    ).install webs, "/webs"

  stopComms: ->
    @comms.close() if @comms
    @status.put 'comms.running', false

  startComms: ->
    #kill old comms if exists
    @config.get 'port.comms', (err, port) =>
      return @log "no comms port set" if err

      @comms = upnode((remote, d) =>
        #for each new connection
        servant = new ServantClient @, d
        #return interface
        return {proxy:proxy servant}
      ).listen port, =>
        @log "comms listening on: #{port}"
        @status.put 'comms.running', true

  stopGit: ->
    @git.close() if @git
    @status.put 'git.running', false

  startGit: ->
    @stopGit()
    @config.get 'port.git', (err, port) =>
      return @log "no git port set" if err

      @repos = pushover path.join dirs.king, 'repos'

      @git = http.createServer((req, res) =>
        @repos.handle req, res
      ).listen port, =>
        @log "git listening on: #{port}"
        @status.put 'git.running', true

      @repos.on 'push', (push) =>
        @log('GIT: push')
        push.accept()
    
      @repos.on 'fetch', (fetch) =>
        @log('GIT: fetch')
        fetch.accept()

      @repos.on 'tag', (tag) =>
        @log('GIT: tag')
        tag.accept()

    # @repos.list (err, rs) =>
    #   @log "GIT: list: ", rs

  startStatsd: ->
    @log('init statsd')


#called via cli
exports.start = (port) -> new KingServer port
