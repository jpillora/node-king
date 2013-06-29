
# split hostname and port out of an origin
exports.host = (host, defaultPort = 5464) ->
  port = null
  if m = @host.match /:(\d+)$/
    port = parseInt m[1], 10
    host = host.replace m[0], ''
  port = defaultPort unless port
  return {host,port}

# retrives current ip from the "most-likely"
# network interface
exports.address = ->
  'localhost'
