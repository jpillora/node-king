var enode = require('enode');

// Create a client api
var client = new enode.Client({
  id: Math.random(),
  hi: function() {
    console.log("client says hi");
  }
}).connect(3000);

client.once('ready', function(server, connection) {
  server.hi();
});