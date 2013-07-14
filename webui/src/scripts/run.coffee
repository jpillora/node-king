

App.run ($rootScope, guid, log, remote, data, store) ->

  log "run webui"
  window.I = log
  window.root = $rootScope

  $rootScope.id = guid()
  $rootScope.log = log
  $rootScope.data = data
  $rootScope.store = store
  $rootScope.remote = remote
  $rootScope.panel = "servants"



  #initial connection
  $rootScope.remote.connect()