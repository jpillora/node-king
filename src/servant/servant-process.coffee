#core
{spawn,fork} = require "child_process"
Base = require "../common/base"
helper = require "../common/helper"

module.exports = class ServantProcess extends Base

  name: "ServantProcess"

  constructor: (@servant, cmd) ->

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
      @log 'stdout', buff.toString()

    @p.stderr.on 'data', (buff) =>
      @log 'stderr', buff.toString()

    @p.on 'close', (code) =>
      @log 'close', code
      @servant.procs.remove @p

    @p.on 'error', (err) =>
      @log 'error', err.toString()
      @servant.procs.remove @p

  log: ->
    args = Array::slice.call arguments
    @servant.remote.proxy 'king.users.remoteProxyAll.log', args

