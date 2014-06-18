jest.dontMock '../src/cordagefile'

describe 'cordagefile', ->

  describe 'read', ->
    it 'should throw an error if Cordagefile.coffee doesn\'t exist', ->
      jest.setMock 'fs', existsSync: -> false

      cordagefile = require '../src/cordagefile'

      expect ->
        cordagefile.read()
      .toThrow 'Cordagefile.coffee not found'
