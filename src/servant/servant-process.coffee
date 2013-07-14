#core
{spawn,fork} = require "child_process"
Base = require "../common/base"
helper = require "../common/helper"

class ServantProcess extends Base

  name: "ServantProcess"

  constructor: (@servant, cmd) ->

    helper.bindAll @

    args = cmd.split /\s+/
    program = args.shift()

    @p = if program is 'node'
      @node = true
      fork args
    else
      @node = false
      spawn program, args

    @servant.procs.add @p

    @id = @p.pid#"#{@p.pid}-#{helper.guid()}"

    @store "execute", cmd

    @p.stdout.on 'data', (buff) =>
      @store 'stdout', buff.toString().replace(/\n$/,'')

    @p.stderr.on 'data', (buff) =>
      @store 'stderr', buff.toString()

    @p.on 'close', (code) =>
      @store 'close', code
      @end()

    @p.on 'error', (err) =>
      @store 'error', err.toString()
      @end()

  store: (type, value) ->
    @servant.db.put "procs.#{@p.pid}.log:#{Date.now()}", {type,value}

  end: ->
    @servant.procs.remove @p

exports.run = (servant, cmd) ->
  sp = new ServantProcess servant, cmd
  sp.id