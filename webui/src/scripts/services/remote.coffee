App.factory 'remote', ($rootScope, log, guid) ->

  #local api
  clientApi = 
    id: guid()
    print: (str) ->
      console

  #create dnode
  d = dnode clientApi

  #remote api
  d.on "remote", (api) ->

    remote.api = api
    remote.api.hi 7, (n) -> log "server says: #{n}"

    log "got remote api", remote
    $rootScope.$emit 'remote-api'

  #pipe dnode into the websockets stream
  d.pipe(shoe "/webs").pipe d

  remote =
    ready: false
    api: null

  return remote