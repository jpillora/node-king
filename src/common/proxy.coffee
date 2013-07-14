
fallbackCallback = ->
  console.log.apply console, ['proxy result:'].concat Array::slice.call arguments

module.exports = (object) ->  ->
  args = Array::slice.call arguments
  
  callback = args[args.length-1]
  if typeof callback isnt 'function'
    callback = fallbackCallback
  path = args.shift()

  if typeof path isnt 'string'
    callback Object.keys obj
    return

  # console.log 'PROXY', path, args.length, callback isnt fallbackCallback
  
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
    # if we've provided a callback that the fn 
    # doesnt seem to accept it, assume sync.
    if callback isnt fallbackCallback and
       args.length is obj.length+1
      callback(res)
  else if typeof obj isnt 'object'
    callback null, obj
  else
    callback Object.keys obj

  42