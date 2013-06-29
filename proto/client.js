var dnode = require('dnode');
var upnode = require('./upnode');

var d = dnode({
  cdec : function (n, cb) {
    cb(--n);
  },
  whynoworkd: 42
});
d.on('remote', function (remote) {
  console.log("got server remote!");
  remote.start(10);
});


d.connect(5004);
d.on('error', function(e) {
  console.log("connection error!");
});
console.log("connecting...");