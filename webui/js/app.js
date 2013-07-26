(function() {
  var App;

  App = angular.module('king-webui', []);

  App.value('data', {});

  App.controller('ConfigController', function($scope) {});

  App.controller('ProcessController', function($scope) {});

  App.controller('ServantController', function($rootScope, $scope, log, remote) {
    var data, proxy, servantPath, userId;
    userId = $rootScope.id;
    data = $scope.servantData;
    $scope.index = null;
    $scope.visible = false;
    $scope.cmd = 'pwd';
    $scope.servantId = data.id;
    $scope.capabilities = _.map(data.capabilities, function(version, prog) {
      return {
        prog: prog,
        version: version
      };
    });
    $scope.processes = [];
    servantPath = "king.servants." + $scope.servantId + ".remote.proxy";
    proxy = function() {
      arguments[0] = servantPath + "." + arguments[0];
      return remote.proxy.apply(null, arguments);
    };
    $scope.toggle = function() {
      var action,
        _this = this;
      action = $scope.visible ? 'remove' : 'add';
      return proxy("watchers." + action, userId, function(res) {
        if (res !== true) {
          return;
        }
        $scope.visible = !$scope.visible;
        log('visible!', $scope.visible);
        return $scope.$apply();
      });
    };
    $scope.exec = function() {
      var proc;
      log('exec!');
      proc = {
        cmd: $scope.cmd
      };
      proxy("exec", $scope.cmd, function(err, pid) {
        return console.log('executing', pid);
      });
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
      log("connecting...");
      d = Node.dnode({
        id: $rootScope.id,
        proxy: Node.proxy($rootScope)
      });
      stream = Node.shoe("/websockets");
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
    remote = {
      connect: connect,
      ready: false
    };
    return remote;
  });

  App.factory('store', function($rootScope, data, log, remote) {
    var init, store;
    store = {
      put: function(k, v) {
        log("put", k, v);
        return data[k] = v;
      },
      del: function(k) {
        return log("del", k);
      },
      batch: function(ops) {
        var op, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = ops.length; _i < _len; _i++) {
          op = ops[_i];
          _results.push(store[op.type](op.key, op.value));
        }
        return _results;
      }
    };
    init = function() {
      return remote.proxy('king.db.getAll', function(err, results) {
        if (err) {
          return log("init store error: " + err);
        }
        return _.each(results, function(v, k) {
          return store.put(k, v);
        });
      });
    };
    if (remote.ready) {
      init();
    } else {
      $rootScope.$on('remote-up', function() {
        var key;
        for (key in data) {
          delete data[key];
        }
        return init();
      });
    }
    return store;
  });

  App.run(function($rootScope, guid, log, remote, data, store) {
    log("run webui");
    window.I = log;
    window.root = $rootScope;
    $rootScope.id = guid();
    $rootScope.log = log;
    $rootScope.data = data;
    $rootScope.store = store;
    $rootScope.remote = remote;
    $rootScope.panel = "servants";
    return $rootScope.remote.connect();
  });

}).call(this);
