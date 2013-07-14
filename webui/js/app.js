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
        remote.ready = true;
        log("connected");
        return $rootScope.$broadcast('remote-up');
      };
      remoteDown = function() {
        d.removeListener("remote", remoteUp);
        $rootScope.$broadcast('remote-down');
        remote.ready = false;
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
      ready: false
    };
    return remote;
  });

  App.factory('store', function($rootScope, log, remote) {
    var init, store;
    store = {
      lvl: Node.levelup('king-db', {
        db: Node.leveljs
      })
    };
    store.lvl.on('ready', function() {
      log('store ready');
      return $rootScope.$emit('store-ready');
    });
    store.lvl.on('put', function(k, v) {
      return log("put '" + k + "'='" + v + "'");
    });
    store.lvl.on('del', function(k, v) {
      return log("del '" + k + "'");
    });
    store.lvl.on('batch', function(b) {
      return log("batch", b);
    });
    init = function() {
      log("get king config");
      return remote.proxy('king.db.getAll', function(err, results) {
        var ops;
        if (err) {
          return log("init error: " + err);
        }
        ops = _.map(results, function(value, key) {
          return {
            type: "put",
            key: key,
            value: value
          };
        });
        if (ops.length > 0) {
          return store.lvl.batch(ops);
        }
      });
    };
    if (remote.ready) {
      init();
    } else {
      $rootScope.$on('remote-up', function() {
        return init();
      });
    }
    return store;
  });

  App.run(function($rootScope, guid, log, remote, store) {
    log("run webui");
    window.I = log;
    window.root = $rootScope;
    $rootScope.id = guid();
    $rootScope.log = log;
    $rootScope.store = store;
    $rootScope.remote = remote;
    return $rootScope.panel = "servants";
  });

}).call(this);
