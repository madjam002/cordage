proxyquire = require 'proxyquire'

describe 'cordagefile', ->

  describe 'read', ->
    it 'should return an error if Cordagefile.coffee doesn\'t exist', (done) ->
      fs = jasmine.createSpyObj 'fs', ['existsSync']
      fs.existsSync.andReturn false

      cordagefile = proxyquire '../src/cordagefile',
        'fs': fs

      cordagefile.read()
      .catch (error) ->
        expect(error.message).toEqual 'Cordagefile.coffee not found'
        done()

    it 'should produce an array of services', ->
      fs = jasmine.createSpyObj 'fs', ['existsSync']
      fs.existsSync.andReturn true

      fileFunction = ->
        @service 'app', description: 'App Server'
      fileFunction['@noCallThru'] = true

      oldCwd = process.cwd
      process.cwd = -> '/tmp'

      cordagefile = proxyquire '../src/cordagefile',
        'fs': fs
        '/tmp/Cordagefile.coffee': fileFunction

      cordagefile.read()

      process.cwd = oldCwd

      expect(cordagefile.services[0].name).toEqual 'app'
