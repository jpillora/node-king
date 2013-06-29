Base = require "../common/base"
ip = require "../common/ip"

module.exports = class Servant extends Base

  constructor: (servantHost, @king) ->

    servant = ip.host servantHost

    @log "retrieving servant interface on #{servant.host}:#{servant.port}..."

    upnode.connect servant.port, servant.host, (remote, conn) =>
