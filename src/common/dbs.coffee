

fs = require "fs"
path = require "path"
levelup = require "levelup"

dirs = require "./dirs"

init = 
  config: [
    {type: 'put', key: 'port.comms', value: 5464}
    {type: 'put', key: 'port.git', value: 54418}
  ]

exports.init = (callback) ->

  #status db setup
  statusPath = path.join dirs.king, 'status.db'
  status = levelup path.join dirs.king, 'status.db'

  #config db setup
  configPath = path.join dirs.king, 'config.db'
  isNew = !fs.existsSync configPath
  config = levelup configPath

  ready = (err) -> callback err, config, status

  if isNew
    config.batch init.config, ready
  else
    ready(null)

