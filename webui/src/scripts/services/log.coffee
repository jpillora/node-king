App.factory 'log', ->

  log = ->
    # return unless window.console
    args = Array::slice.call arguments
    console.log.apply console, args

  return log