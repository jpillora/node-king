
mkdirp = require "mkdirp"
path = require "path"
fs = require "fs"

# library dir
exports.root = path.join __dirname, '..', '..'
# king
home = process.env.USERPROFILE or process.env.HOME or process.env.HOMEPATH
exports.king = path.join home, '.king'

#make if missing
unless fs.existsSync exports.king
  mkdirp.sync exports.king