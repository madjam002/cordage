jest.dontMock '../../src/util/service-builder'

describe 'service builder', ->

  beforeEach ->
    jest.dontMock 'path'

  describe 'build', ->
    it 'should generate a service file using the config', ->
      fs = require 'fs'
      mkdirp = require 'mkdirp'

      jest.setMock 'swig', compileFile: -> -> 'template contents'

      ServiceBuilder = require '../../src/util/service-builder'

      builder = new ServiceBuilder 'app', description: 'App Server'
      builder.build()

      expect(fs.writeFileSync).toBeCalledWith(
        "#{process.cwd()}/.cordage/services/app.v1.1.service", 'template contents'
      )
      expect(mkdirp.sync).toBeCalledWith "#{process.cwd()}/.cordage/services"
