q = require 'q'
proxyquire = require 'proxyquire'

describe 'unit builder', ->

  describe 'build', ->
    it 'should generate a unit file using the config', (done) ->
      fs = jasmine.createSpyObj 'fs', ['writeFileSync']
      mkdirp = jasmine.createSpyObj 'mkdirp', ['sync']
      swig = jasmine.createSpyObj 'swig', ['compileFile']

      config =
        servicesPath: '/tmp/services'

      swig.compileFile.andReturn ->
        'template contents'

      UnitBuilder = proxyquire '../src/unit-builder',
        'fs': fs
        'mkdirp': mkdirp
        'swig': swig

      service =
        description: 'App Server'
        name: 'app'
        config: {}

      builder = new UnitBuilder config
      builder.build service, '14.04', 1
      .then ->
        expect(fs.writeFileSync).toHaveBeenCalledWith(
          "/tmp/services/app.v14-04.1.service", 'template contents'
        )
        expect(mkdirp.sync).toHaveBeenCalledWith '/tmp/services'

        done()
