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

    @log "init dbs..."
    Database.init initDb, @gotDB

  gotDB: (err, @db) ->
    return "config error: #{err}" if err

    @initWeb()
    @initGit()
    @initComms()

    @startServer(@webPort)

    # @startStatsd()

    #pass db changes through to users (and to servants?)
    @db.change (type, args) =>
      args = Array::slice.call args
      args.unshift "store.lvl.#{type}"
      @users.proxyAll.apply @users, args

  startServer: (port) ->

    @http = http.createServer((req, res) =>

      console.log(">>", req.url, req.headers)

      if /^git/i.test(req.headers?['user-agent'])
        @repos.handle req, res
      else if /^dnode/i.test(req.headers?['user-agent'])
        console.log 'dnode', req, res
      else
        @staticFiles req, res

    ).listen port, =>
      @log "http listening on: #{port}"

    #web sockets will steal the connection if it matches this url
    @websockets.install @http, "/websockets"

  initWeb: ->
    opts =
      root: path.join dirs.root, 'webui'
      cache: 0

    @users = new List

    @users.on 'add', (webUser) =>
      #on connection - send all servants
      webUser.remote.proxy 'servants.add', @servants.serialize()

    @users.on 'remove', (webUser) =>
      #remove watcher from all servants
      @servants.proxyAll 'watchers.remove', webUser.id

    @websockets = shoe (stream) =>
      #for each new connection
      webUser = new WebUser @, stream

      webUser.once 'connected', =>
        @users.add webUser

      webUser.once 'disconnected', =>
        @users.remove webUser

    #static file handler
    @staticFiles = ecstatic opts


  stopComms: ->
    return unless @comms
    @servants.destroy()
    @comms.close()
    @comms = null
    @db.status 'comms.running', false

  initComms: ->
    @servants = new List
    @servants.on 'change', (action, servant) =>
      @users.proxyAll "servants.#{action}", servant.serialize()

    @comms = upnode((remote, dnode) =>
      #for each new connection
      servant = new ServantClient @, dnode

      servant.once 'connected', =>
        @servants.add servant

      servant.once 'disconnected', =>
        @servants.remove servant

      #return interface
      return {proxy:proxy servant}
    )

  stopGit: ->
    return unless @git
    @git.close()
    @git = null
    @db.status 'git.running', false

  initGit: ->
    return if @git
    @stopGit()

    @repos = pushover path.join dirs.king, 'repos'

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
