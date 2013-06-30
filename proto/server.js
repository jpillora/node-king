var upnode = require('upnode');

var server = upnode(function(remote, d) {
  //will fire on each connection
   
  //expose an interface to the client 
  this.s = function () {
    console.log("server hit, hitting '%s' back...", remote.id);
    remote.c();
  };

  //d is the dnode connection
  d.on('remote', function(remote, a, b) {
    console.log('got client remote:', Object.keys(remote));
  });

  d.on('end', function() {
    console.log("server lost connection to '%s'", remote.id);
  });

}).listen(5004, function() {
  console.log("listening...");
});

