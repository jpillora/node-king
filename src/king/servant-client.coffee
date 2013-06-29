Base = require "../common/base"
ip = require "../common/ip"
upnode = require "upnode"

module.exports = class ServantClient extends Base

  name: 'ServantClient'

  constructor: (servantHost, @king) ->

    servant = ip.host servantHost

    @log "retrieving servant interface on #{servant.host}:#{servant.port}..."

    upnode.connect servant.port, servant.host, (remote, conn) =>

      @log "servant added"


