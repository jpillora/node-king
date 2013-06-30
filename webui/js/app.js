(function() {
  var App;

  App = angular.module('king-webui', []);

  App.controller('ConfigController', function($scope) {});

  App.controller('ServantsController', function($scope, log) {
    window.serv = $scope;
    $scope.servants = [];
    $scope.$on('servants-init', function(event, servants) {
      return $scope.servants = servants;
    });
    $scope.$on('servants-add', function(event, servant) {
      return $scope.servants.push(data);
    });
    return $scope.$on('servants-remove', function(event, servant) {
      var i, result;
      result = _.find($scope.servants, function(s) {
        return servant.id === s.id;
      });
      if (!result) {
        return;
      }
      i = $scope.servants.indexOf(result);
      return $scope.servants.splice(i, 1);
    });
  });

  App.factory('guid', function() {
    return function() {
      return (Math.random() * Math.pow(2, 32)).toString(16);
    };
  });

  App.factory('log', function() {
    var log;
    log = function() {
      var args;
      args = Array.prototype.slice.call(arguments);
      return console.log.apply(console, args);
    };
    return log;
  });

  App.factory('remote', function($rootScope, log, guid) {
    var connect, localApi, newRemote, remote;
    localApi = {
      id: guid(),
      log: log,
      broadcast: function() {
        log('broadcast', arguments);
        return $rootScope.$broadcast.apply($rootScope, arguments);
      }
    };
    newRemote = function(remoteApi) {
      remote.api = remoteApi;
      log("got remote api", remote.api);
      return $rootScope.$emit('remote-api');
    };
    connect = function() {
      var d, stream,
        _this = this;
      d = dnode(localApi);
      d.on("remote", newRemote);
      stream = shoe("/webs");
      d.pipe(stream).pipe(d);
      return stream.on('end', function(msg) {
        d.removeListener("remote", newRemote);
        d = null;
        stream = null;
        log("connection lost, reconnecting in 5 seconds...");
        return setTimeout(connect, 5000);
      });
    };
    connect();
    remote = {
      reconnect: connect,
      ready: false,
      api: null
    };
    return remote;
  });

  App.factory('store', function($rootScope, log, remote) {
    var getAll, store;
    store = levelup('web-config', {
      db: leveljs
    });
    store.on('ready', function() {
      log('store ready');
      return $rootScope.$emit('store-ready');
    });
    getAll = function() {};
    if (remote.ready) {
      getAll();
    } else {
      $rootScope.$on('remote-api', getAll);
    }
    return store;
  });

  App.run(function($rootScope, log, remote, store) {
    log("run webui");
    window.I = log;
    window.root = $rootScope;
    window.store = store;
    window.remote = remote;
    return $rootScope.panel = "servants";
  });

}).call(this);
