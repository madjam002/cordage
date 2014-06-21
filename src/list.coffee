Table = require 'cli-table'
chalk = require 'chalk'
string = require 'string'

log = require './log'
fleetctl = require './fleetctl'
cordagefile = require './cordagefile'
Service = require './service'

# Public: Lists the services and units in the cluster.
#
# Units will be displayed per service in a table for readability.
module.exports =
class List

  constructor: (program) ->
    program
    .command 'list'
    .description 'view services in the cluster'
    .action @run

  # Public: Run the list command.
  run: =>
    cordagefile.read()

    .then -> fleetctl.listUnits()
    .then (units) =>

      for service in cordagefile.services
        console.log()
        console.log chalk.bold('==>'), chalk.bold.blue(string(service.name).padRight(15)), service.config.description

        # create and populate table
        table = @createUnitTable()
        table.populate service, units

        console.log table.toString()

      console.log()

    .catch (err) ->
      log.error 'An error has occured whilst retrieving running services', err.toString()

  # Private: Creates a new cli table instance.
  createUnitTable: ->
    table = new Table
      head: ['Unit Name', 'State', 'Active', 'Host Machine']
      colWidths: [ 17, 12, 12, 17 ]
      style:
        compact: true

    # Populate the table with units
    table.populate = (service, units) ->
      for unit in units
        unitService = Service.fromUnitName unit.unit, cordagefile.services

        if unitService is service
          table.push [
            string(unit.unit).chompRight('.service').toString()
            unit.state
            unit.active or '-'
            unit.ip or '-'
          ]

    return table
