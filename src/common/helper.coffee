
exports.guid = -> (Math.random()*Math.pow(2,32)).toString(16)

exports.bindAll = (obj, to = obj) ->
  for key, val of obj
    if typeof val is 'function'
      obj[key] = val.bind to
  return obj

exports.type = (obj) ->
  return /\[object (\w+)\]/.test(Object::toString.call(obj)) and RegExp.$1.toLowerCase()

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

exports.tap = (obj, fnName, fn) ->
  unless typeof obj[fnName] is 'function'
    console.log "object has no '#{fnName}' function"
    return
  orig = obj[fnName]
  obj[fnName] = ->
    fn.apply obj, arguments
    orig.apply obj, arguments