var upnode = require('upnode');

var id = process.argv[2];
if(!id) console.log("choose an id") || process.exit(1);

var d = upnode({
  id: id,
  c: function () {
    console.log("client %s hit.", id);
  }
}).connect(5004);

d.on('remote', function (remote) {
  console.log("hitting server...");
  remote.s();
});


d.on('error', function(e) {
  console.log("connection error!");
});

d.on('end', function() {
  console.log("lost connection to server");
});

console.log("connecting...");
// d.connect(5004);