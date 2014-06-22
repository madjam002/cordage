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
    unitBuilder = new UnitBuilder @config

    cordagefile.read()

    .then ->
      services = cordagefile.services

      log.action 'Retrieving version information about services...'

      # get latest image tag from docker index for each service
      q.all cordagefile.services.map (service) ->
        registryApi.getLatestTagForImage service.config.image
        .then (tag) ->
          service.tag = tag

    .then ->
      log.action 'Checking for existing units...'
      fleetctl.listUnits()

    .then (units) ->
      q.all cordagefile.services.map (service) ->

        # find existing units for this service
        serviceUnits = _.filter units, (unit) -> unit.belongsTo(service) and unit.isVersion(service.tag.name)

        if serviceUnits.length > 0
          service.unitCount = serviceUnits.length
          log.info service.name, "#{serviceUnits.length} unit(s) have already been deployed for version #{service.tag.name}"
        else
          log.info service.name, "No units have been deployed for version #{service.tag.name}"

          oldServiceUnits = _.filter units, (unit) -> unit.belongsTo(service) and not unit.isVersion(service.tag.name)
          unitsByVersion = _.groupBy oldServiceUnits, 'version'
          oldUnitCount = _.max(unitsByVersion, (unit, key) -> unit.length).length

          service.unitCount = oldUnitCount

          if oldUnitCount > 0
            log.info service.name, "#{oldUnitCount} unit(s) already exist for a previous version"
          else
            log.info service.name, "No units exist for any previous versions"

        log.info service.name, "Building #{service.unitCount} unit(s)"

        service.build unitBuilder, service.tag.name

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
