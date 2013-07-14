
_ = require "lodash"
fs = require "fs"
path = require "path"
levelup = require "levelup"
dirs = require "./dirs"
Base = require "./base"

#static vars
name = "king.db"
path = path.join dirs.king, name

class Database extends Base
  name: "Database"
  constructor: (init, callback) ->

    isNew = !fs.existsSync path
    @lvl = levelup path

    @log if isNew then 'created' else 'loaded'

    #steal some methods
    ['get','put','del','batch','on'].forEach (method) =>
      @[method] = @lvl[method].bind @lvl

    @namespace 'config'
    @namespace 'status'

    if isNew
      @prefill callback, init
    else
      callback null, @

  prefill: (callback, init) ->
    batch = _.map init, (value, key) -> {type: 'put', key, value }
    @log "prefill", batch
    @lvl.batch batch, (err) =>
      callback err, @

  change: (fn) ->
    #.on(change-events...)
    ['put', 'del', 'batch'].forEach (event) =>
      @lvl.on event, -> fn.call null, event, arguments
    null

  namespace: (prefix) ->
    @[prefix] = (key, value, cb) ->
      if typeof value is 'function' and typeof cb is 'undefined'
        cb = value
        @get "#{prefix}.#{key}", cb
      else
        @put "#{prefix}.#{key}", value, cb
    true

  getAll: (cb) ->
    @queryAll {}, cb
    null

  queryAll: (query, cb) ->
    results = {}
    data = (obj) =>
      results[obj.key] = obj.value
    error = (err) =>
      cb err, null
    end = (err) =>
      cb null, results
    @lvl.createReadStream(query).on('data',data).on('error',error).on('end',end)
    null

  # get: (key, cb) ->
  #   @lvl.get key, cb

  # put: (key, value, cb) ->
  #   @lvl.put key, value, cb

#public interface
exports.init = (init, callback) ->
  new Database init, callback
  null

