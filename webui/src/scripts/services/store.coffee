App.factory 'store', ($rootScope, log) ->

  db = levelup('foo', { db: leveljs })

  db.on 'ready', ->
    log 'store ready'
    $rootScope.$emit 'ready.store'

  return db