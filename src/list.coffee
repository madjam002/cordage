Table = require 'cli-table'
chalk = require 'chalk'
string = require 'string'

fleetctl = require './fleetctl'
cordagefile = require './cordagefile'
Service = require './service'

module.exports =
  run: ->
    cordagefile.read()

    fleetctl.listUnits()

    .then (units) ->

      for service in cordagefile.services
        console.log()
        console.log chalk.bold('==>'), chalk.bold.blue(string(service.name).padRight(15)), service.config.description

        table = new Table
          head: ['Unit Name', 'State', 'Active', 'Host Machine']
          colWidths: [ 17, 12, 12, 17 ]
          style:
            compact: true


        for unit in units
          unitService = Service.fromFileName unit.unit, cordagefile.services

          if unitService is service
            table.push [
              string(unit.unit).chompRight '.service'
              unit.state
              unit.active
              unit.ip
            ]

        console.log table.toString()

      console.log()
