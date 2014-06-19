string = require 'string'

serviceBuilder = require './service-builder'

module.exports =
class Service
  constructor: (@name, @config) ->
    @version = 'v1' # TODO generate somehow
    @instanceCount = 1 # TODO scaling
    @fileName = "#{@name}.#{@version}"
    @filePath = "#{serviceBuilder.servicesPath}/#{@fileName}.*.service"

  build: ->
    serviceBuilder this, index for index in [1..@instanceCount]

  @fromFileName = (fileName, services) ->
    for service in services
      if string(fileName).startsWith service.fileName
        return service
