fs = require 'fs'
q = require 'q'

Service = require './service'

module.exports =
  services: []

  # Public: Read Cordagefile.coffee in the current directory.
  read: ->
    deferred = q.defer()
    path = "#{process.cwd()}/Cordagefile.coffee"

    # check for cordagefile
    unless fs.existsSync path
      deferred.reject new Error('Cordagefile.coffee not found')
      return deferred.promise

    # register coffeescript and require cordagefile
    require('coffee-script').register()
    cordagefile = require path

    # create the context which will be passed to the cordagefile exports function
    context =
      service: (name, options) =>
        @services.push new Service(name, options)

    # finally invoke the cordagefile exports function with the context
    cordagefile.call context

    deferred.resolve()
    return deferred.promise
