
async = require "async"
{exec} = require "child_process"

version = /\d+\.\d+\.\d+/
#
versionCmds = [
  {name: "node"}
  {name: "ruby"}
  {name: "go"}
  {name: "git"}
  {name: "npm"}
  {name: "mongod"}
]

exports.calculate = (callback) ->

  caps = {}

  has = (cmd, callback) ->

    cmd.args = '--version' unless cmd.args
    cmdString = "#{cmd.name} #{cmd.args}"

    exec cmdString, (err, stdout, stderr) ->
      caps[cmd.name] = if m = stdout?.match version or 
                          m = stderr?.match version
        m[0]
      else
        null
      callback()

  async.each versionCmds, has, ->
    callback caps
  
  null