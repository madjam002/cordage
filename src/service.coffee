string = require 'string'
q = require 'q'
PropertyAccessors = require 'property-accessors'

# Public: Represents a single service.
module.exports =
class Service
  PropertyAccessors.includeInto this

  _unitCount = 0

  # Public: Contains the units associated with this service.
  units: []

  constructor: (@name, @config) ->
    @minUnits = @config?.minUnits or 1

  # Public: Indicates how many units there should be for this service.
  @::accessor 'unitCount',
    get: ->
      if _unitCount > @minUnits then _unitCount else @minUnits
    set: (value) ->
      _unitCount = value

  # Public: Builds unit files for this service.
  build: (unitBuilder, version) =>
    q.all [1..@unitCount].map (index) =>
      unitBuilder.build this, version, index
    .then (@units) =>

  # Public: Parse a service name
  @parseName: (name) ->
    # check for version in name
    if string(name).contains ':'
      version = name.substring name.indexOf(':') + 1
      name = name.substring 0, name.indexOf ':'

    name: name
    version: version
