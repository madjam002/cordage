string = require 'string'

serviceBuilder = require './service-builder'

# Public: Represents a single Service.
module.exports =
class Service

  constructor: (@name, @config) ->
    @version = 'v1' # TODO generate somehow
    @instanceCount = 1 # TODO scaling
    @fileName = "#{@name}.#{@version}"
    @filePath = "#{serviceBuilder.servicesPath}/#{@fileName}.*.service"

  # Public: Builds serviced files for this service.
  build: ->
    serviceBuilder this, index for index in [1..@instanceCount]

  # Public: Creates a new Service instance from the given fleet unit name.
  @fromUnitName = (unitName, services) ->
    for service in services
      if string(unitName).startsWith service.fileName
        return service
