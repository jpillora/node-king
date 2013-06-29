var dnode = require('dnode');
// var upnode = require('./upnode');

var d = dnode(function(remote, conn) {
  this.s = function () {
    console.log("server hit, hitting '%s' back...", remote.id);
    remote.c();
  };

  conn.on('end', function() {
    console.log("server lost connection to '%s'", remote.id);
  });
});

d.listen(5004);
console.log("listening...");

