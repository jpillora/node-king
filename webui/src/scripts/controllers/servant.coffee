App.controller 'ServantController', ($scope, log, remote) ->

  data = $scope.servantData

  $scope.index = null
  $scope.visible = false
  $scope.cmd = 'pwd'
  $scope.id = data.id
  $scope.capabilities = _.map data.capabilities, (version, prog) -> { prog, version }
  $scope.processes = []

  $scope.exec = ->
    log 'exec!'
    proc = { cmd: $scope.cmd }
    remote.proxy "king.servants.#{$scope.id}.remote.proxy.exec", $scope.cmd


    # $scope.index, "remote.exec", proc.cmd, (event) ->
    #   if /^(std|err)/.test event.type
    #     proc[event.type] = event.msg
    #   else if event.type is 'close'
    #     proc.code = event.code
    #   $scope.$digest()
    $scope.processes.push proc

  $scope.debug = (s) ->
    s.ctrl = $scope