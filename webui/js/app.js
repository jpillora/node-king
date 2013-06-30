(function() {
  var App;

  App = angular.module('king-webui', []);

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
    var clientApi, d, remote;
    clientApi = {
      id: guid(),
      print: function(str) {
        return console;
      }
    };
    d = dnode(clientApi);
    d.on("remote", function(api) {
      remote.api = api;
      remote.api.hi(7, function(n) {
        return log("server says: " + n);
      });
      log("got remote api", remote);
      return $rootScope.$emit('remote-api');
    });
    d.pipe(shoe("/webs")).pipe(d);
    remote = {
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
    return window.remote = remote;
  });

}).call(this);
