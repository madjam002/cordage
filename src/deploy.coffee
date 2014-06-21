q = require 'q'
_ = require 'lodash'

Service = require './service'
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

    .then ->
      services = cordagefile.services

      log.action 'Checking for existing units...'
      fleetctl.listUnits()

    .then (units) ->
      q.all cordagefile.services.map (service) ->

        # find existing units for this service
        serviceUnits = _.filter units, (unit) ->
          true if Service.fromUnitName(unit.unit, [ service ]) is service

        if serviceUnits.length > 0
          log.info service.name, "#{serviceUnits.length} unit(s) have already been deployed"

        # deploy the same amount of units as there are deployed already
        service.unitCount = serviceUnits.length
        log.info service.name, "Building #{service.unitCount} unit(s)"

        service.build unitBuilder

    .then ->
      log.action 'Pushing units...'
      q.all services.map (service) ->
        q.all service.units.map (unit) ->
          fleetctl.submit unit.path

    .then ->
      log.action 'Starting services...'
      q.all services.map (service) ->
        log.info service.name, 'Starting'

        q.all service.units.map (unit) ->
          fleetctl.start unit.path

    .catch (err) ->
      log.error 'An error has occured whilst deploying', err.toString()
