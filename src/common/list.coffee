{EventEmitter} = require "events"

module.exports = class List extends EventEmitter

  constructor: ->
    @_array = []

  get: (i) ->
    @_array[i]

  add: (item) ->
    @_array.push item
    @emit 'add', item
    @

  remove: (item) ->
    i = @_array.indexOf item
    return false if i is -1
    @_array.splice i,1
    @emit 'remove', item
    @


  each: (fn) ->
    @_array.forEach fn
    @

  map: (fn) ->
    @_array.map fn