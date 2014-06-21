path = require 'path'
fs = require 'fs'
swig = require 'swig'
mkdirp = require 'mkdirp'
_ = require 'lodash'

resourcesPath = path.resolve "#{__dirname}/../resources"

templates =
  service: swig.compileFile "#{resourcesPath}/service.tmpl"

# Public: Generates unit files.
module.exports =
class UnitBuilder

  constructor: (@registryApi, @config) ->

  # Public: Generates a unit file for the given service.
  build: (service, instance) =>
    @registryApi.getLatestTagForImage service.config.image
    .then (tag) =>
      fileName = "#{service.name}.v#{tag.name.replace(/\./g, '-')}"
      fullFileName = "#{fileName}.#{instance}"

      # generate service template using service configuration
      output = templates.service
        name: service.name
        fileName: fileName
        fullFileName: fullFileName
        instance: instance
        version: service.version

        pullTimeout: service.config.pullTimeout or 0

        image: "#{service.config.image}:#{tag.name}"
        description: service.config.description

        ports: _.pairs service.config.ports
        rules: service.config.rules

      # determine service file path and write service file
      filePath = "#{@config.servicesPath}/#{fullFileName}.service"

      mkdirp.sync @config.servicesPath
      fs.writeFileSync filePath, output

      return filePath
