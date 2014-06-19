q = require 'q'

build = require './build'
log = require './log'
fleetctl = require './fleetctl'

module.exports =
  run: ->
    services = []

    build.build()

    .then (_services_) ->
      services = _services_
      log.action 'Pushing services...'
      fleetctl.submit services.map (service) -> service.filePath

    .then ->
      log.action 'Starting services...'
      q.all services.map (service) ->
        log.info service.name, 'Starting'
        fleetctl.start service.filePath
