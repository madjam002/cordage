fs = require 'fs'

Service = require './service'

module.exports =
  services: []

  read: ->
    path = "#{process.cwd()}/Cordagefile.coffee"

    # check for cordagefile
    unless fs.existsSync path
      throw new Error 'Cordagefile.coffee not found'

    # register coffeescript and require cordagefile
    require('coffee-script').register()
    cordagefile = require path

    # create the context which will be passed to the cordagefile exports function
    context =
      service: (name, options) =>
        @services.push new Service(name, options)

    # finally invoke the cordagefile exports function with the context
    cordagefile.call context
