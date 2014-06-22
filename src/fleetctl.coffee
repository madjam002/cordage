q = require 'q'
fleetctl = require('fleetctl')()

Unit = require './unit'

module.exports =
  # Public: Run `fleetctl list-units`
  listUnits: ->
    deferred = q.defer()

    fleetctl.list_units (err, fleetUnits) ->
      deferred.reject err if err

      units = []
      for fleetUnit in fleetUnits
        units.push new Unit fleetUnit.unit, fleetUnit

      deferred.resolve units unless err

    return deferred.promise

  # Public: Run `fleetctl submit [units]`
  submit: (units) ->
    deferred = q.defer()

    fleetctl.submit units, (err) ->
      deferred.reject err if err
      deferred.resolve() unless err

    return deferred.promise

  # Public: Run `fleetctl start [units]`
  start: (units) ->
    deferred = q.defer()

    fleetctl.start units, (err) ->
      deferred.reject err if err
      deferred.resolve() unless err

    return deferred.promise

  # Public: Run `fleetctl destroy [units]`
  destroy: (units) ->
    deferred = q.defer()

    fleetctl.destroy units, (err) ->
      deferred.reject err if err
      deferred.resolve() unless err

    return deferred.promise
