path = require 'path'
fs = require 'fs'
swig = require 'swig'
mkdirp = require 'mkdirp'

resourcesPath = path.resolve "#{__dirname}/../resources"
servicesPath = "#{process.cwd()}/.cordage/services"

templates =
  service: swig.compileFile "#{resourcesPath}/service.tmpl"

module.exports = (service, config) ->
  version = 'v1' # TODO generate somehow
  instance = 1 # TODO generate somehow
  serviceName = "#{service}.#{version}.#{instance}"
  serviceNameWildcard = "#{service}.#{version}.*"

  # generate service template using service configuration
  output = templates.service
    service: service
    serviceName: serviceName
    serviceNameWildcard: serviceNameWildcard

    timeout: config.timeout

    image: config.image
    description: config.description

    rules: config.rules

  # determine service file path and write service file
  filePath = "#{servicesPath}/#{serviceName}.service"

  mkdirp.sync servicesPath
  fs.writeFileSync filePath, output

  return filePath
