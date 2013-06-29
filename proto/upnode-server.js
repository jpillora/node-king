var upnode = require('upnode');

var server = upnode(function (client, conn) {
    this.time = function (cb) { cb(new Date().toString()) };
});
server.listen(7000);