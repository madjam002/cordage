q = require 'q'
_ = require 'lodash'
string = require 'string'

log = require './log'
fleetctl = require './fleetctl'
cordagefile = require './cordagefile'
Service = require './service'

# Public: Destroys all units associated with the given service.
module.exports =
class Destroy

  constructor: (program) ->
    program
    .command 'destroy <service>'
    .description 'stops and destroys all units for the given service'
    .action @run

  # Public: Run the destroy command.
  run: (serviceName) ->
    service = null
    cordagefile.read()

    .then ->
      # find service by name
      service = _.find cordagefile.services, name: serviceName
      throw new Error "Service \"#{serviceName}\" not found" unless service?

    .then -> fleetctl.listUnits()

    .then (units) ->
      # find only units associated with the service we want to destroy
      _.filter units, (unit) ->
        true if Service.fromUnitName(unit.unit, [ service ]) is service

    .then (units) ->
      if units.length is 0
        log.action 'No units found, nothing to destroy.'
        return

      log.action "Destroying #{serviceName}..."

      # run `fleet destroy` for each unit
      q.all units.map (unit) ->
        log.info string(unit.unit).chompRight('.service').toString(), 'Destroying'
        fleetctl.destroy unit.unit

    .then -> log.action "#{serviceName} has been destroyed."

    .catch (err) ->
      log.error "An error has occured whilst destroying \"#{serviceName}\"", err.toString()
