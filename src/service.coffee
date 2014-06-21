string = require 'string'
q = require 'q'
PropertyAccessors = require 'property-accessors'

# Public: Represents a single Service.
module.exports =
class Service
  PropertyAccessors.includeInto this

  _unitCount = 0

  # Public: Contains the file paths for any generated unit files.
  units: []

  constructor: (@name, @config) ->
    @minUnits = @config.minUnits or 1

  # Public: Indicates how many units there should be for this service.
  @::accessor 'unitCount',
    get: ->
      if _unitCount > @minUnits then _unitCount else @minUnits
    set: (value) ->
      _unitCount = value

  # Public: Builds unit files for this service.
  build: (unitBuilder) =>
    q.all [1..@unitCount].map (index) =>
      unitBuilder.build this, index
    .then (@units) =>

  # Public: Creates a new Service instance from the given unit name.
  @fromUnitName = (unitName, services) ->
    for service in services
      if string(unitName).startsWith "#{service.name}.v"
        return service
