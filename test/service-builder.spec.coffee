proxyquire = require 'proxyquire'

describe 'service builder', ->

  describe 'build', ->
    it 'should generate a service file using the config', ->
      fs = jasmine.createSpyObj 'fs', ['writeFileSync']
      mkdirp = jasmine.createSpyObj 'mkdirp', ['sync']
      swig = jasmine.createSpyObj 'swig', ['compileFile']

      swig.compileFile.andReturn ->
        'template contents'

      builder = proxyquire '../src/service-builder',
        'fs': fs
        'mkdirp': mkdirp
        'swig': swig

      service =
        description: 'App Server'
        fileName: 'app.v1'
        config: {}

      builder service, 1

      expect(fs.writeFileSync).toHaveBeenCalledWith(
        "#{process.cwd()}/.cordage/services/app.v1.1.service", 'template contents'
      )
      expect(mkdirp.sync).toHaveBeenCalledWith "#{process.cwd()}/.cordage/services"
