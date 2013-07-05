App.controller 'ServantsController', ($rootScope, $scope, log) ->

  $rootScope.servants = $scope

  $scope.list = []

  $scope.add = (obj) ->
    if _.isArray obj
      _.each obj, $scope.add
      return
    
    $scope.list.push obj
    $scope.$apply()

  $scope.remove = (obj) ->
    if _.isArray obj
      _.each obj, $scope.remove
      return

    result = _.find $scope.list, (s) ->
      s.id is obj.id

    return unless result
    i = $scope.list.indexOf result
    $scope.list.splice i,1
    $scope.$apply()

  $scope.reset = ->
    $scope.list = []
    $scope.$apply()

  $rootScope.$on 'remote-down', $scope.reset

