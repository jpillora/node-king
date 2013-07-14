

App.run ($rootScope, guid, log, remote, store) ->

  log "run webui"
  window.I = log
  window.root = $rootScope

  $rootScope.id = guid()
  $rootScope.log = log
  $rootScope.store = store
  $rootScope.remote = remote
  $rootScope.panel = "servants"

