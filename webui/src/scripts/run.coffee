

App.run ($rootScope, guid, log, remote, store) ->

  $rootScope.id = guid()
  $rootScope.log = log

  log "run webui"
  window.I = log
  window.root = $rootScope
  window.store = store
  window.remote = remote

  $rootScope.panel = "servants"

