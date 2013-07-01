App.controller 'ServantController', ($scope, log, remote) ->

  $scope.index = null
  $scope.visible = false
  $scope.cmd = 'pwd'


  $scope.id = $scope.servantData.id
  $scope.capabilities = []

  for prog, version of $scope.servantData.capabilities
    $scope.capabilities.push {prog, version}

  $scope.processes = []

  $scope.exec = ->
    log 'exec!'
    proc = { cmd: $scope.cmd }
    remote.api.exec $scope.index, proc.cmd, (event) ->
      if /^(std|err)/.test event.type
        proc[event.type] = event.msg
      else if event.type is 'close'
        proc.code = event.code
      $scope.$digest()
    $scope.processes.push proc


  $scope.debug = (s) ->
    s.ctrl = $scope