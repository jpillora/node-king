App.factory 'store', ($rootScope, log, remote) ->

  store = {
    lvl: Node.levelup 'king-db', db: Node.leveljs
  }
  
  store.lvl.on 'ready', ->
    log 'store ready'
    $rootScope.$emit 'store-ready'

  store.lvl.on 'put', (k,v) ->
    log "put '#{k}'='#{v}'"

  store.lvl.on 'del', (k,v) ->
    log "del '#{k}'"

  store.lvl.on 'batch', (b) ->
    log "batch", b

  #init store
  init = ->
    log "get king config"
    remote.proxy 'king.db.getAll', (err, results) ->
      return log("init error: #{err}") if err
      ops = _.map results, (value,key) -> { type: "put", key, value }
      if ops.length > 0
        store.lvl.batch ops
  
  if remote.ready
    init()
  else
    $rootScope.$on 'remote-up', ->
      #wipe
      init()

  
  return store