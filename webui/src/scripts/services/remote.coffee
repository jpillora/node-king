App.factory 'remote', ($rootScope, log) ->

  #remote connect
  connect = ->

    log "connecting..."
    #create dnode
    d = Node.dnode
      id: $rootScope.id
      proxy: Node.proxy $rootScope

    #pipe dnode into the websockets stream
    stream = Node.shoe "/websockets"
    d.pipe(stream).pipe d

    remoteUp = (remoteApi) ->
      remote.proxy = remoteApi.proxy
      remote.ready = true
      log "connected"
      $rootScope.$broadcast 'remote-up'

    remoteDown = ->
      $rootScope.$broadcast 'remote-down'
      remote.ready = false
      log "disconnected, retrying in 5..."
      setTimeout connect, 5000

    #remote api
    d.once "remote", remoteUp
    stream.once 'end', remoteDown

  remote = 
    connect: connect
    ready: false

  return remote