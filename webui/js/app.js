(function() {
  var App;

  App = angular.module('king-webui', []);

  App.controller('ConfigController', function($scope) {});

  App.controller('ProcessController', function($scope) {});

  App.controller('ServantController', function($scope, log, remote) {
    var data;
    data = $scope.servantData;
    $scope.index = null;
    $scope.visible = false;
    $scope.cmd = 'pwd';
    $scope.id = data.id;
    $scope.capabilities = _.map(data.capabilities, function(version, prog) {
      return {
        prog: prog,
        version: version
      };
    });
    $scope.processes = [];
    $scope.exec = function() {
      var proc;
      log('exec!');
      proc = {
        cmd: $scope.cmd
      };
      remote.proxy("king.servants." + $scope.id + ".remote.proxy.exec", $scope.cmd);
      return $scope.processes.push(proc);
    };
    return $scope.debug = function(s) {
      return s.ctrl = $scope;
    };
  });

  App.controller('ServantsController', function($rootScope, $scope, log) {
    $rootScope.servants = $scope;
    $scope.list = [];
    $scope.add = function(obj) {
      if (_.isArray(obj)) {
        _.each(obj, $scope.add);
        return;
      }
      $scope.list.push(obj);
      return $scope.$apply();
    };
    $scope.remove = function(obj) {
      var i, result;
      if (_.isArray(obj)) {
        _.each(obj, $scope.remove);
        return;
      }
      result = _.find($scope.list, function(s) {
        return s.id === obj.id;
      });
      if (!result) {
        return;
      }
      i = $scope.list.indexOf(result);
      $scope.list.splice(i, 1);
      return $scope.$apply();
    };
    $scope.reset = function() {
      $scope.list = [];
      return $scope.$apply();
    };
    return $rootScope.$on('remote-down', $scope.reset);
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

  App.factory('remote', function($rootScope, log) {
    var connect, remote;
    connect = function() {
      var d, remoteDown, remoteUp, stream;
      d = Node.dnode({
        id: $rootScope.id,
        proxy: Node.proxy($rootScope)
      });
      stream = Node.shoe("/webs");
      d.pipe(stream).pipe(d);
      remoteUp = function(remoteApi) {
        remote.proxy = remoteApi.proxy;
        log("connected");
        return $rootScope.$broadcast('remote-up');
      };
      remoteDown = function() {
        d.removeListener("remote", remoteUp);
        $rootScope.$broadcast('remote-down');
        d = null;
        stream = null;
        log("disconnected, retrying in 5...");
        return setTimeout(connect, 5000);
      };
      d.on("remote", remoteUp);
      return stream.on('end', remoteDown);
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
    store = Node.levelup('web-config', {
      db: Node.leveljs
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

  App.run(function($rootScope, guid, log, remote, store) {
    $rootScope.id = guid();
    $rootScope.log = log;
    log("run webui");
    window.I = log;
    window.root = $rootScope;
    window.store = store;
    window.remote = remote;
    return $rootScope.panel = "servants";
  });

}).call(this);
