
exports.guid = -> (Math.random()*Math.pow(2,32)).toString(16)

exports.bindAll = (obj, to = obj) ->
  for key, val of obj
    if obj.hasOwnProperty key
      if typeof val is 'function'
        obj[key] = val.bind to
      # else if typeof val is 'object'
      #   obj[key] = exports.bind val, to
  return obj

exports.host = 
  # split hostname and port out of an origin
  parse: (host, defaultPort = 5464) ->
    port = null
    if m = host.match /:(\d+)$/
      port = parseInt m[1], 10
      host = host.replace m[0], ''
    port = defaultPort unless port
    return {host,port}

  # retrives current ip from the "most-likely"
  # network interface
  address: ->
    'localhost'


function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };