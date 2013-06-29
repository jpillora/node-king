
module.exports = class Base

  name: 'Base'

  constructor: ->
    @log 'init base' 

  toString: ->
    @name

  log: ->
    args = Array::slice.call arguments
    args.unshift @toString() + ':'
    console.log.apply console, args