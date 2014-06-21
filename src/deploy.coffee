q = require 'q'

log = require './log'
fleetctl = require './fleetctl'
cordagefile = require './cordagefile'
ServiceBuilder = require './service-builder'
RegistryApi = require './registry-api'

# Public: Builds and deploys the application to the cluster.
module.exports =
class Deploy

  registryApi = null
  serviceBuilder = null

  constructor: (program, @config) ->
    program
    .command 'deploy'
    .description 'builds and deploys your application'
    .action @run

  # Public: Run the deploy command.
  run: =>
    services = null
    registryApi = new RegistryApi
    serviceBuilder = new ServiceBuilder registryApi, @config

    cordagefile.read()

    .then =>
      services = cordagefile.services
      @buildServices()

    .then ->
      services = cordagefile.services
      log.action 'Pushing services...'
      q.all services.map (service) ->
        q.all service.instances.map (instance) ->
          fleetctl.submit instance

    .then ->
      log.action 'Starting services...'
      q.all services.map (service) ->
        log.info service.name, 'Starting'

        q.all service.instances.map (instance) ->
          fleetctl.start instance

    .catch (err) ->
      log.error 'An error has occured whilst deploying', err.toString()

  # Public: Build serviced files for each service in Cordagefile.coffee
  buildServices: ->
    log.action 'Building services...'

    q.all cordagefile.services.map (service) ->
      log.info service.name, 'Building'
      service.build serviceBuilder
