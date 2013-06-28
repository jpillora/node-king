Base = require "../common/base"

module.exports = class Servant extends Base

  constructor: ->
    super
    @log 'init servant' 