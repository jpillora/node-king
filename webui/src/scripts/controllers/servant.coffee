App.controller 'ServantController', ($rootScope, $scope, log, remote) ->

  userId = $rootScope.id
  data = $scope.servantData

  $scope.index = null
  $scope.visible = false
  $scope.cmd = 'pwd'
  $scope.servantId = data.id
  $scope.capabilities = _.map data.capabilities, (version, prog) -> { prog, version }
  $scope.processes = []

  servantPath = "king.servants.#{$scope.servantId}.remote.proxy"

  proxy = ->
    arguments[0] = servantPath + "." + arguments[0]
    remote.proxy.apply null,  arguments

  $scope.toggle = ->
    action = if $scope.visible then 'remove' else 'add'
    proxy "watchers.#{action}", userId, (res) =>
      if res isnt true
        return
      $scope.visible = !$scope.visible
      log 'visible!', $scope.visible
      $scope.$apply()

  $scope.exec = ->
    log 'exec!'
    proc = { cmd: $scope.cmd }
    proxy "exec", $scope.cmd, (err, pid) ->
      console.log 'executing', pid


    # $scope.index, "remote.exec", proc.cmd, (event) ->
    #   if /^(std|err)/.test event.type
    #     proc[event.type] = event.msg
    #   else if event.type is 'close'
    #     proc.code = event.code
    #   $scope.$digest()
    $scope.processes.push proc

  $scope.debug = (s) ->
    s.ctrl = $scope