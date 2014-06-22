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
    {name, version} = Service.parseName serviceName

    service = null
    units = null
    cordagefile.read()

    .then ->
      # find service by name
      service = _.find cordagefile.services, name: name
      throw new Error "Service \"#{name}\" not found" unless service?

    .then -> fleetctl.listUnits()

    .then (units) ->
      if version?
        # find units which are associated with the service and version specified
        _.filter units, (unit) -> unit.belongsTo(service) and unit.isVersion(version)
      else
        # find only units associated with the service we want to destroy
        _.filter units, (unit) -> unit.belongsTo service

    .then (serviceUnits) ->
      units = serviceUnits

      if units.length is 0
        throw new Error 'No units found, nothing to destroy.'

      # prompt user if --force wasn't provided
      unless options.force
        if version?
          message = "Are you sure you want to destroy version #{version} units for the #{name} service?"
        else
          message = "Are you sure you want to destroy ALL units for the #{name} service?"

        q.promise (resolve) ->
          inquirer.prompt [
            type: 'confirm'
            name: 'confirm'
            default: false
            message: message
          ], resolve
        .then (answer) ->
          throw new Error 'Cancelled' unless answer.confirm

    .then ->
      if version?
        log.action "Destroying version #{version} of #{name}..."
      else
        log.action "Destroying all versions of #{name}..."

      # run `fleet destroy` for each unit
      q.all units.map (unit) ->
        log.info string(unit.name).chompRight('.service').toString(), 'destroying'
        fleetctl.destroy unit.name

    .then -> log.action "#{name} has been destroyed."

    .catch (err) ->
      log.error "An error has occured whilst destroying \"#{name}\"", err.toString()
