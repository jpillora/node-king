var enode = require('enode');

// Create a client api
var server = new enode.Server({
  hi: function() {
    console.log("server says hi");
  }
}).listen(3000);

server.on('connect', function(client, connection) {
  client.hi();
  connection.on('end', function() {
    console.log("client: " + client.id + " died");
    console.log(server.connections.map(function(c) { return c.remote.id; }));
  });
});