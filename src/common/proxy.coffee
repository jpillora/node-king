
module.exports = (object) ->  ->
  args = Array::slice.call arguments
  
  callback = args[args.length-1]
  callback = (-> console.log.apply console, arguments) if typeof callback isnt 'function'
  path = args.shift()

  if typeof path isnt 'string'
    callback "proxy path isnt a string (#{path})"
    return
  
  ps = path.split('.')

  obj = object
  while ps.length
    name = ps.shift()
    pobj = obj
    obj = obj[name]
    type = typeof obj
    #invalid path
    if type is 'undefined'
      console.log Object.keys pobj
      return callback("prop '#{name}' is undefined")
    #path remaining and function - is another proxy
    if ps.length and type is 'function'
      args.unshift(ps.join('.'))
      break
  
  if typeof obj is 'function'
    res = obj.apply(pobj, args)
    if obj.length is 0
      callback(res)
  else if typeof obj isnt 'object'
    callback null, obj
  else
    callback Object.keys obj

  null