
# {EventEmitter} = require "events"

module.exports = class Base# extends EventEmitter

  name: 'Base'

  constructor: ->
    @log 'init base' 

  toString: ->
    if @id then "#{@name} (#{@id})" else @name

  consargs: (a) ->
    args = Array::slice.call a
    args.unshift @toString() + ':'
    args

  log: ->   console.log.apply   console, @consargs arguments
  error: -> console.error.apply console, @consargs arguments