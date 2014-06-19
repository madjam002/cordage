q = require 'q'

log = require './log'
cordagefile = require './cordagefile'
Service = require './service'

module.exports =
  build: ->
    cordagefile.read()

    log.action 'Building services...'
    services = []

    for service, config of cordagefile.services
      log.info service, 'Building'

      service = new Service service, config
      service.build()

      services.push service

    q services
