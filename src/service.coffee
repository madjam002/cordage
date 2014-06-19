serviceBuilder = require './service-builder'

module.exports =
class Service
  constructor: (@name, @config) ->

  build: ->
    @filePath = serviceBuilder @name, @config
