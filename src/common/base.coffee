
helper = require "./helper"
prepend = (obj, args)-> ["#{obj.toString()}:"].concat Array::slice.call args

module.exports = class Base

  name: 'Base'

  toString: ->
    if @id then "#{@name} (#{@id})" else @name

  log: ->
    console.log.apply console, prepend @, arguments
    null
  
  err: ->
    console.error.apply console, prepend @, arguments
    throw "error, see log"