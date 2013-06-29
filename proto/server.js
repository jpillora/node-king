var dnode = require('dnode');
var upnode = require('./upnode');

var d = dnode({
  start: function(n) {
    console.log("start ", n);
  },
  sdec : function (n, cb) {
    cb(--n);
  }
});
d.listen(5004);
console.log("listening...");

d.on('remote', function (remote) {
  console.log("got client remote!");
});

