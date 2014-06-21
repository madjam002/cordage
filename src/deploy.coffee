q = require 'q'

log = require './log'
fleetctl = require './fleetctl'
cordagefile = require './cordagefile'
UnitBuilder = require './unit-builder'
RegistryApi = require './registry-api'

# Public: Builds and deploys the application to the cluster.
module.exports =
class Deploy

  registryApi = null
  unitBuilder = null

  constructor: (program, @config) ->
    program
    .command 'deploy'
    .description 'builds and deploys your application'
    .action @run

  # Public: Run the deploy command.
  run: =>
    services = null
    registryApi = new RegistryApi
    unitBuilder = new UnitBuilder registryApi, @config

    cordagefile.read()

    .then =>
      services = cordagefile.services
      @buildServices()

    .then ->
      services = cordagefile.services
      log.action 'Pushing units...'
      q.all services.map (service) ->
        q.all service.units.map (unit) ->
          fleetctl.submit unit

    .then ->
      log.action 'Starting units...'
      q.all services.map (service) ->
        log.info service.name, 'Starting'

        q.all service.units.map (unit) ->
          fleetctl.start unit

    .catch (err) ->
      log.error 'An error has occured whilst deploying', err.toString()

  # Public: Build unit files for each service in Cordagefile.coffee
  buildServices: ->
    log.action 'Building units...'

    q.all cordagefile.services.map (service) ->
      log.info service.name, 'Building'
      service.build unitBuilder
