(function() {
  var App;

  App = angular.module('king-webui', []);

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
    var d, obj, stream;
    obj = {};
    stream = shoe("/webs");
    d = dnode({
      print: function(str) {
        return console;
      }
    });
    d.on("remote", function(remote) {
      log("connected to server", remote);
      remote.hi(7, function(n) {
        return log("server says: " + n);
      });
      obj.prototype = remote;
      return $rootScope.$emit('new.remote');
    });
    d.pipe(stream).pipe(d);
    return obj;
  });

  App.factory('store', function($rootScope, log) {
    var db;
    db = levelup('foo', {
      db: leveljs
    });
    db.on('ready', function() {
      log('store ready');
      return $rootScope.$emit('ready.store');
    });
    return db;
  });

  App.run(function($rootScope, log, remote, store) {
    window.root = $rootScope;
    return log("run webui");
  });

}).call(this);
