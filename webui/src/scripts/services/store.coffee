App.factory 'store', ($rootScope, log, remote) ->

  store = Node.levelup 'web-config', db: Node.leveljs

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