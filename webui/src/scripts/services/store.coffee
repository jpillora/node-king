App.factory 'store', ($rootScope, data, log, remote) ->

  #public api
  store =
    put: (k, v) ->
      log "put",k,v
      data[k] = v
    del: (k) ->
      log "del",k
    batch: (ops) ->
      for op in ops
        store[op.type](op.key,op.value)

  #init store
  init = ->
    remote.proxy 'king.db.getAll', (err, results) ->
      return log("init store error: #{err}") if err
      _.each results, (v,k) -> store.put k,v
  
  if remote.ready
    init()
  else
    $rootScope.$on 'remote-up', ->
      #wipe first
      for key of data
        delete data[key]
      init()

  return store