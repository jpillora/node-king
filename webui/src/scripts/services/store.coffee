App.factory 'store', ($rootScope, log, remote) ->

  store = levelup 'web-config', db:leveljs

  store.on 'ready', ->
    log 'store ready'
    $rootScope.$emit 'store-ready'

  #init store
  getAll = ->



  if remote.ready
    getAll()
  else
    $rootScope.$on 'remote-api', getAll
  

  return store