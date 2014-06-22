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
          log.info service.name, "now at version #{tag.name}"

    .then ->
      log.action 'Checking for existing units...'
      fleetctl.listUnits()

    .then (units) ->
      q.all cordagefile.services.map (service) ->

        # find existing units for this service with the latest version
        serviceUnits = _.filter units, (unit) -> unit.belongsTo(service) and unit.isVersion(service.tag.name)

        if serviceUnits.length > 0
          # units already exist for this version, deployment probably isn't necessary
          service.unitCount = serviceUnits.length
          log.info service.name, "#{serviceUnits.length} unit(s) have already been deployed for version #{service.tag.name}"

        else
          # no units exist for this version
          log.info service.name, "no units have been deployed for version #{service.tag.name}"

          # find all units which are any version apart from the latest
          oldServiceUnits = _.filter units, (unit) -> unit.belongsTo(service) and not unit.isVersion(service.tag.name)
          # group these units by version
          unitsByVersion = _.groupBy oldServiceUnits, 'version'
          # get the highest amount of units grouped by version
          oldUnitCount = _.max(unitsByVersion, (unit, key) -> unit.length).length

          # this is now how many units we should deploy for the new version
          service.unitCount = oldUnitCount

          if oldUnitCount > 0
            log.info service.name, "#{oldUnitCount} unit(s) already exist for a previous version"
          else
            log.info service.name, "no units exist for any previous versions"

        # now build x amount of units (determined above) for the service
        log.info service.name, "building #{service.unitCount} unit(s)"

        service.build unitBuilder, service.tag.name

    .then ->
      log.action 'Pushing units...'
      q.all services.map (service) ->
        # submit each unit for this service
        q.all service.units.map (unit) ->
          fleetctl.submit unit.path

    .then ->
      log.action 'Starting services...'
      q.all services.map (service) ->
        log.info service.name, "starting #{service.units.length} unit(s)"

        # start each unit for this service
        q.all service.units.map (unit) ->
          fleetctl.start unit.path

    .catch (err) ->
      log.error 'An error has occured whilst deploying', err.toString()
