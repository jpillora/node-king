App.factory 'remote', ($rootScope, log) ->

  obj = {}

  stream = shoe "/webs"
  d = dnode
    print: (str) -> console

  d.on "remote", (remote) ->
    log "connected to server", remote
    remote.hi 7, (n) ->
      log "server says: #{n}"

    obj.prototype = remote
    $rootScope.$emit 'new.remote'

  d.pipe(stream).pipe d

  return obj