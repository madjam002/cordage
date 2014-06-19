q = require 'q'
fleetctl = require('fleetctl')()

module.exports =
  listUnits: ->
    deferred = q.defer()

    fleetctl.list_units (err, units) ->
      deferred.reject err if err
      deferred.resolve units unless err

    return deferred.promise

  submit: (units) ->
    deferred = q.defer()

    fleetctl.submit units, (err) ->
      deferred.reject err if err
      deferred.resolve() unless err

    return deferred.promise

  start: (units) ->
    deferred = q.defer()

    fleetctl.start units, (err) ->
      deferred.reject err if err
      deferred.resolve() unless err

    return deferred.promise
