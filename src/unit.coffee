path = require 'path'
string = require 'string'

# Public: Represents a fleet unit associated with a cordage service.
module.exports =
class Unit

  constructor: (pathOrName, state) ->
    @name = path.basename pathOrName

    nameParts = @name.split '.'
    @serviceName = nameParts[0]
    @version = string(nameParts[1]).chompLeft('v').toString()
    @instance = parseInt nameParts[2]

    if string(pathOrName).startsWith('/') or string(pathOrName).startsWith('.')
      @path = pathOrName

    {@state, @active, @ip} = state if state?

  # Public: Indicates whether this unit belongs to the given service.
  belongsTo: (service) =>
    string(@name).startsWith "#{service.name}.v"

  # Public: Indicates whether the given version identifier is the same as the given version.
  isVersion: (version) =>
    version.replace(/\./g, '-') is @version
