pkg = require("../../package.json")
program = require("commander")

# this cli is - purposefully - as small as possible
# all settings should be configured over the king web ui

#cli init
program.version pkg.version
program.usage "rule [http-port] OR serve host[:dnode-port]"
program.option "--king-dir [dir]", "The directory used to store the king database [~/.king/]", "~/.king/"
program.on '--help', ->
  console.log """
  \  Examples:
       king rule
       king rule 5480
       king serve 10.0.1.2
       king serve 10.0.1.2:5464
  \  Notes:
       king default http port is 5480
       servant default dnode port is 5464 (KING)
       king dnode port can be changed via the WebUI
  """


program.parse process.argv

action = program.args[0]

unless action in ["rule","serve"]
  console.log("You must either 'rule' or 'serve'...")
  program.help()

type = if action is "rule" then "king" else "servant"

#set king directory first!
dirs = require "../common/dirs"
dirs.setKingDir program.kingDir

#load server type
server = require "../#{type}/#{type}-server"

#fire up a king
if type is "king"
  str = program.args[1]
  port = if str then parseInt str, 10
  if str isnt `undefined` and isNaN(port) or (0 >= port >= 65535)
    console.log "A king cannot rule on the port: '#{str}'..."
    program.help()

  server.start port

#fire up a servant
else if type is "servant"

  addr = program.args[1]
  if not addr
    console.log "You must serve a particular king..."
    program.help()

  server.start addr


