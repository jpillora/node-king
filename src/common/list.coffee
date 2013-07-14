proxy = require "./proxy"
Base = require "./base"

module.exports = class List extends Base

  name: 'List'

  constructor: ->
    @_array = []
    Object.defineProperty @, 'length', get: => @_array.length

  get: (i) ->
    @_array[i]

  has: (item) ->
    @_array.indexOf(item) >= 0

  add: (item) ->
    if @has item
      # cb false if cb
      return false 
    @_array.push item
    @[item.id] = item if item.id
    @emit 'change', 'add', item
    @emit 'add', item
    # cb true if cb
    return true

  remove: (item) ->
    i = @_array.indexOf item
    if i is -1
      # cb false if cb
      return false 
    delete @[item.id] if item.id
    @_array.splice i,1
    @emit 'change', 'remove', item
    @emit 'remove', item
    # cb true if cb
    return true

  each: (fn) ->
    @_array.forEach fn
    true

  map: (fn) ->
    @_array.map fn

  serialize: ->
    @map (item) -> item?.serialize()

  destroy: ->
    @each (item) ->
      if typeof item.destroy is 'function'
        item.destroy()
    @_array = null

  proxyAll: ->
    args = arguments
    @each (item) =>
      if item.remote?.proxy
        item.remote.proxy.apply item, args
    null

