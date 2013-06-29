var upnode = require('upnode');

var d = upnode(function(remote, conn) {
  this.s = function () {
    console.log("server hit, hitting '%s' back...", remote.id);

    console.log(Object.keys(remote));
    remote.c();
  };

  conn.on('end', function() {
    console.log("server lost connection to '%s'", remote.id);
  });
});

d.listen(5004, function() {
  console.log("listening...");
});

