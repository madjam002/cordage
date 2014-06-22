path = require 'path'
fs = require 'fs'
swig = require 'swig'
mkdirp = require 'mkdirp'
_ = require 'lodash'
q = require 'q'

Unit = require './unit'

resourcesPath = path.resolve "#{__dirname}/../resources"

templates =
  service: swig.compileFile "#{resourcesPath}/service.tmpl"

# Public: Generates unit files.
module.exports =
class UnitBuilder

  constructor: (@config) ->

  # Public: Generates a unit file for the given service.
  build: (service, version, instance) =>
    fileName = "#{service.name}.v#{version.replace(/\./g, '-')}"
    fullFileName = "#{fileName}.#{instance}"

    # generate service template using service configuration
    output = templates.service
      name: service.name
      fileName: fileName
      fullFileName: fullFileName
      instance: instance
      version: version

      pullTimeout: service.config.pullTimeout or 0

      image: "#{service.config.image}:#{version}"
      description: service.config.description

      ports: _.pairs service.config.ports
      rules: service.config.rules

    # determine service file path and write service file
    filePath = "#{@config.servicesPath}/#{fullFileName}.service"

    mkdirp.sync @config.servicesPath
    fs.writeFileSync filePath, output

    unit = new Unit filePath
    unit.service = service

    return q unit
