q = require 'q'
_ = require 'lodash'
string = require 'string'
inquirer = require 'inquirer'

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
    .option '-f, --force', 'skip prompts'
    .action @run

  # Public: Run the destroy command.
  run: (serviceName, options) ->
    service = null
    units = null
    cordagefile.read()

    .then ->
      # find service by name
      service = _.find cordagefile.services, name: serviceName
      throw new Error "Service \"#{serviceName}\" not found" unless service?

    .then -> fleetctl.listUnits()

    .then (units) ->
      # find only units associated with the service we want to destroy
      _.filter units, (unit) ->
        true if Service.fromUnitName(unit.name, [ service ]) is service

    .then (serviceUnits) ->
      units = serviceUnits

      if units.length is 0
        throw new Error 'No units found, nothing to destroy.'

      # prompt user if --force wasn't provided
      unless options.force
        q.promise (resolve) ->
          inquirer.prompt [
            type: 'confirm'
            name: 'confirm'
            default: false
            message: "Are you sure you want to destroy ALL units for the #{serviceName} service?"
          ], resolve
        .then (answer) ->
          throw new Error 'Cancelled' unless answer.confirm

    .then ->
      log.action "Destroying #{serviceName}..."

      # run `fleet destroy` for each unit
      q.all units.map (unit) ->
        log.info string(unit.name).chompRight('.service').toString(), 'Destroying'
        fleetctl.destroy unit.name

    .then -> log.action "#{serviceName} has been destroyed."

    .catch (err) ->
      log.error "An error has occured whilst destroying \"#{serviceName}\"", err.toString()
