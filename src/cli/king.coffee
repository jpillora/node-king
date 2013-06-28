#!/usr/bin/env node

pkg = require("../../package.json")
program = require("commander")
# exec = require("child_process").exec
# fs = require("fs")

#cli init
program.version pkg.version
program.usage "<rule [port]|serve host[:port]>"
program.on '--help', ->
  console.log """
  \  Examples:
       king rule
       king rule 5464
       king serve 10.0.1.2
       king serve 10.0.1.2:5464

  \  Notes:
       default port is KING (5464)

  """
program.parse process.argv

action = program.args[0]

unless action in ["rule","serve"]
  console.log("You must either 'rule' or 'serve'...")
  program.help()

type = if action is "rule" then "king" else "servant"

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


