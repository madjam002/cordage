q = require 'q'

log = require './log'
cordagefile = require './cordagefile'

module.exports =
  build: ->
    cordagefile.read()

    log.action 'Building services...'

    for service in cordagefile.services
      log.info service.name, 'Building'

      service.build()

    q cordagefile.services
