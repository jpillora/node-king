
async = require "async"
{exec} = require "child_process"

semvar = /\d+\.\d+\.\d+/
#
versionCmds = [
  {name: "node"}
  {name: "ruby"}
  {name: "go"}
  {name: "git"}
  {name: "npm"}
  {name: "mongod"}
  {name: "redis"}
]

exports.calculate = (callback) ->

  caps = {}

  has = (cmd, callback) ->

    cmd.args = '--version' unless cmd.args
    cmdString = "#{cmd.name} #{cmd.args}"

    exec cmdString, (err, stdout, stderr) ->
      caps[cmd.name] = if m = stdout?.match semvar or 
                          m = stderr?.match semvar
        m[0]
      else
        null
      callback()

  async.each versionCmds, has, ->
    callback caps
  
  null