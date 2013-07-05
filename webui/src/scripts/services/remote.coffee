App.factory 'remote', ($rootScope, log) ->

  #remote connect
  connect = ->

    #create dnode
    d = Node.dnode
      id: $rootScope.id
      proxy: Node.proxy $rootScope

    #pipe dnode into the websockets stream
    stream = Node.shoe "/webs"
    d.pipe(stream).pipe d

    remoteUp = (remoteApi) ->
      remote.proxy = remoteApi.proxy
      log "connected"
      $rootScope.$broadcast 'remote-up'

    remoteDown = ->
      d.removeListener "remote", remoteUp
      $rootScope.$broadcast 'remote-down'
      d = null
      stream = null
      log "disconnected, retrying in 5..."
      setTimeout connect, 5000

    #remote api
    d.on "remote", remoteUp
    stream.on 'end', remoteDown

  #initial connection
  connect()

  remote = 
    reconnect: connect
    ready: false
    api: null

  return remote