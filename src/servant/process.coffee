#core
{spawn,fork} = require "child_process"
Base = require "../common/base"
helper = require "../common/helper"

module.exports = class ServantProcess extends Base

  name: "Process"

  constructor: (@servant, cmd) ->

    @id = "..."

    helper.bindAll @

    args = cmd.split /\s+/
    program = args.shift()

    @p = if program is 'node'
      fork args
    else
      spawn program, args

    @id = "#{@p.pid}-#{helper.guid()}"

    @log "executing: #{cmd}!"

    @p.stdout.on 'data', (buff) =>
      @broadcast 'stdout', buff.toString()

    @p.stderr.on 'data', (buff) =>
      @broadcast 'stderr', buff.toString()

    @p.on 'close', (code) =>
      @broadcast 'close', code
      @servant.procs.remove @p

    @p.on 'error', (err) =>
      @broadcast 'error', err.toString()
      @servant.procs.remove @p

  broadcast: ->
    args = Array::slice.call arguments
    args[0] = "process-#{args[0]}"
    args.splice 1, 0, @id
    @servant.broadcast.apply @, args

