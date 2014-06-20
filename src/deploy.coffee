q = require 'q'

build = require './build'
log = require './log'
fleetctl = require './fleetctl'
cordagefile = require './cordagefile'

# Public: Builds and deploys the application to the cluster.
module.exports =
class Deploy

  constructor: (program) ->
    program
    .command 'deploy'
    .description 'builds and deploys your application'
    .action @run

  # Public: Run the deploy command.
  run: =>
    services = null
    cordagefile.read()

    .then =>
      services = cordagefile.services
      @buildServices()

    .then ->
      services = cordagefile.services
      log.action 'Pushing services...'
      fleetctl.submit services.map (service) -> service.filePath

    .then ->
      log.action 'Starting services...'
      q.all services.map (service) ->
        log.info service.name, 'Starting'
        fleetctl.start service.filePath

    .catch (err) ->
      log.error 'An error has occured whilst deploying', err.toString()

  # Public: Build serviced files for each service in Cordagefile.coffee
  buildServices: ->
    log.action 'Building services...'

    for service in cordagefile.services
      log.info service.name, 'Building'

      service.build()
