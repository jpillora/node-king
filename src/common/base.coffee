
helper = require "./helper"

# {EventEmitter} = require "events"

module.exports = class Base# extends EventEmitter

  name: 'Base'

  constructor: ->
    @log 'init base' 

  toString: ->
    if @id then "#{@name} (#{@id})" else @name

  proxy: ->
    args = Array::slice.call arguments

    arg0 = helper.type args[0]
    while arg0 is 'arguments' or arg0 is 'array'
      args = Array::slice.call args[0]
      arg0 = helper.type args[0]

    callback = args[args.length - 1]
    callback = @log if typeof callback isnt 'function'
    methodPath = args.shift()

    if typeof methodPath isnt 'string' 
      return callback('method path must be a string')

    method = @
    for key in methodPath.split('.')
      that = method
      method = method[key]
      unless method
        return callback("method '#{methodPath}' is missing")

    if typeof method isnt 'function'
      return callback("method '#{methodPath}' is not a function")

    method.apply that, args 

  consargs: (a) ->
    args = Array::slice.call a
    args.unshift @toString() + ':'
    args

  log: ->   console.log.apply   console, @consargs arguments
  error: -> console.error.apply console, @consargs arguments