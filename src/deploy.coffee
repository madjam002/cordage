build = require './build'

module.exports =
  run: (environment) ->
    build.build()
