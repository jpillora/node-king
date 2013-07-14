#core
http = require "http"
path = require "path"
#vendor
pushover = require "pushover"
upnode = require "upnode"
shoe = require "shoe"
ecstatic = require "ecstatic"
#local
Database = require "../common/database"
Base = require "../common/base"
helper = require "../common/helper"
proxy = require "../common/proxy"
dirs = require "../common/dirs"
List = require "../common/list"
ServantClient = require "./servant-client"
WebUser = require "./web-user"

#initialize config with:
initDb =
  'config.comms.port': 5464
  'config.git.port': 5418

class KingServer extends Base

  name: "KingServer"

  constructor: (@webPort = 5480) ->

    helper.bindAll @
    @servants = new List
    @users = new List

    @log "init dbs..."
    Database.init initDb, @gotDB

  gotDB: (err, @db) ->
    return "config error: #{err}" if err

    @startWeb(@webPort)
    @startStatsd()
    @startGit()
    @startComms()

    #pass db changes through to users (and to servants?)
    @db.change (type, args) =>
      args = Array::slice.call args
      args.unshift "store.lvl.#{type}"
      @users.proxyAll.apply @users, args

  startWeb: (port) ->
    opts =
      root: path.join dirs.root, 'webui'
      cache: 0

    webs = http.createServer(ecstatic opts).listen port, =>
      @log "webs listening on: #{port}"
      @db.config 'port.web', port

    sock = shoe((stream) =>
      #for each new connection
      new WebUser @, stream

    ).install webs, "/webs"

  stopComms: ->
    return unless @comms
    @comms.close()
    @comms = null
    @db.status 'comms.running', false

  startComms: ->
    return if @comms
    @db.config 'comms.port', (err, port) =>
      return @log "no comms port set" if err

      @comms = upnode((remote, d) =>
        #for each new connection
        servant = new ServantClient @, d
        #return interface
        return {proxy:proxy servant}
      ).listen port, =>
        @log "comms listening on: #{port}"
        @db.status 'comms.running', true

  stopGit: ->
    return unless @git
    @git.close()
    @git = null
    @db.status 'git.running', false

  startGit: ->
    return if @git
    @stopGit()
    @db.config 'git.port', (err, port) =>
      return @log "no git port set" if err

      @repos = pushover path.join dirs.king, 'repos'

      @git = http.createServer((req, res) =>
        @repos.handle req, res
      ).listen port, =>
        @log "git listening on: #{port}"
        @db.status 'git.running', true

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
