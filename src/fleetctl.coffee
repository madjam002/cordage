q = require 'q'
fleetctl = require('fleetctl')()

module.exports =
  # Public: Run `fleetctl list-units`
  listUnits: ->
    deferred = q.defer()

    fleetctl.list_units (err, units) ->
      deferred.reject err if err
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
