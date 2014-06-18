cordagefile = require './cordagefile'
ServiceBuilder = require './util/service-builder'

module.exports =
  build: ->
    console.log 'Building services...'

    # read cordagefile
    cordagefile.read()

    for service, config of cordagefile.services
      console.log "Building #{service}"

      builder = new ServiceBuilder service, config
      builder.build()
