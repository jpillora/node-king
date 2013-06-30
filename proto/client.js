var upnode = require('upnode');

var id = process.argv[2];
if(!id) console.log("choose an id") || process.exit(1);

//exposed client interface
var client = upnode({
  id: id,
  c: function () {
    console.log("client %s hit.", id);
  }
});

console.log("connecting...");

//create a dnode connection
var d = client.connect(5004);

//will fire once the server's remote interface is usable
d.on('remote', function (remote) {
  console.log('got server remote:', Object.keys(remote));
  console.log("hitting server...");
  remote.s();
});

d.on('error', function(e) {
  console.log("connection error!");
});

d.on('end', function() {
  console.log("lost connection to server");
});
