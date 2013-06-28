
module.exports = class Base

  name: 'Base'

  constructor: ->
    @log 'init base' 

  log: ->
    args = Array::slice.call arguments
    args.unshift @name
    console.log.apply console, args