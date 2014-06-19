path = require 'path'
fs = require 'fs'
swig = require 'swig'
mkdirp = require 'mkdirp'

resourcesPath = path.resolve "#{__dirname}/../resources"
servicesPath = "#{process.cwd()}/.cordage/services"

templates =
  service: swig.compileFile "#{resourcesPath}/service.tmpl"

module.exports = (service, instance) ->
  fullFileName = "#{service.fileName}.#{instance}"

  # generate service template using service configuration
  output = templates.service
    name: service.name
    fileName: service.fileName
    fullFileName: fullFileName
    instance: instance
    version: service.version

    pullTimeout: service.config.pullTimeout or 0

    image: service.config.image
    description: service.config.description

    rules: service.config.rules

  # determine service file path and write service file
  filePath = "#{servicesPath}/#{fullFileName}.service"

  mkdirp.sync servicesPath
  fs.writeFileSync filePath, output


module.exports.servicesPath = servicesPath
