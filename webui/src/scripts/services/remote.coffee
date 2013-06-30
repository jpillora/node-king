App.factory 'remote', ($rootScope, log, guid) ->

  #local api
  localApi = 
    id: guid()
    log: log
    #allow server to $rootScope.$broadcast
    broadcast: ->
      log 'broadcast', arguments
      $rootScope.$broadcast.apply $rootScope, arguments

  newRemote = (remoteApi) ->
    remote.api = remoteApi
    log "got remote api", remote.api
    $rootScope.$emit 'remote-api'

  #remote connect
  connect = ->
    #create dnode
    d = dnode localApi

    #remote api
    d.on "remote", newRemote

    #pipe dnode into the websockets stream
    stream = shoe "/webs"

    d.pipe(stream).pipe d

    stream.on 'end', (msg) =>
      d.removeListener "remote", newRemote
      d = null
      stream = null
      log "connection lost, reconnecting in 5 seconds..."
      setTimeout connect, 5000

  #initial connection
  connect()

  remote = 
    reconnect: connect
    ready: false
    api: null

  return remote