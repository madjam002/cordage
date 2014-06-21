string = require 'string'
q = require 'q'

# Public: Represents a single Service.
module.exports =
class Service

  instances: []

  constructor: (@name, @config) ->
    @instanceCount = 1 # TODO scaling

  # Public: Builds serviced files for this service.
  build: (serviceBuilder) =>
    q.all [1..@instanceCount].map (index) =>
      serviceBuilder.build this, index
    .then (@instances) =>

  # Public: Creates a new Service instance from the given fleet unit name.
  @fromUnitName = (unitName, services) ->
    for service in services
      if string(unitName).startsWith "#{service.name}.v"
        return service
