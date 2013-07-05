App.controller 'ServantsController', ($scope, log) ->

  window.serv = $scope

  $scope.servants = []

  get = (id) ->
    

  $scope.$on 'servant-process-stdout', (event, id, pid, output) ->
    


  $scope.$on 'servants-init', (event, servants) ->
    $scope.servants = servants

  $scope.$on 'servants-add', (event, servant) ->
    $scope.servants.push servant

  $scope.$on 'servants-remove', (event, servant) ->
    result = _.find $scope.servants, (s) ->
      servant.id is s.id

    return unless result

    i = $scope.servants.indexOf result
    $scope.servants.splice i,1