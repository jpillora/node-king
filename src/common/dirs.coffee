# king directories

mkdirp = require "mkdirp"
path = require "path"
fs = require "fs"

# home dir
home = process.env.USERPROFILE or process.env.HOME or process.env.HOMEPATH

# library dir
exports.root = path.join __dirname, '..', '..'

# king dir
exports.king = null

exports.setKingDir = (dir) ->
  dir = dir.replace /^~\//, home + path.sep
  #make if missing
  unless fs.existsSync dir
    console.log "CREATING", dir
    mkdirp.sync dir

  exports.king = dir
