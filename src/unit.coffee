path = require 'path'
string = require 'string'

# Public: Represents a fleet unit associated with a cordage service.
module.exports =
class Unit

  constructor: (pathOrName) ->
    @name = path.basename pathOrName

    if string(pathOrName).startsWith '/' or string(pathOrName).startsWith '.'
      @path = pathOrName
