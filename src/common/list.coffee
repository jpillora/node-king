proxy = require "./proxy"
{EventEmitter} = require "events"

module.exports = class List extends EventEmitter

  constructor: ->
    @_array = []

  get: (i) ->
    @_array[i]

  add: (item) ->
    @_array.push item
    @[item.id] = item if item.id
    @emit 'add', item
    @

  remove: (item) ->
    i = @_array.indexOf item
    return false if i is -1
    delete @[item.id] if item.id
    @_array.splice i,1
    @emit 'remove', item
    @

  each: (fn) ->
    @_array.forEach fn
    @

  map: (fn) ->
    @_array.map fn

  serialize: ->
    @map (item) -> item?.serialize()

  remoteProxyAll: ->
    args = arguments
    @each (item) =>
      if item.remote?.proxy
        item.remote.proxy.apply item, args
    null

