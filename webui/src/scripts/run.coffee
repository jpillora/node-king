

App.run ($rootScope, log, remote, store) ->

  log "run webui"
  window.I = log
  window.root = $rootScope
  window.store = store
  window.remote = remote

  $rootScope.panel = "servants"

