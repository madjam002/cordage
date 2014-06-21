q = require 'q'
proxyquire = require 'proxyquire'

describe 'service builder', ->

  describe 'build', ->
    it 'should generate a service file using the config', (done) ->
      fs = jasmine.createSpyObj 'fs', ['writeFileSync']
      mkdirp = jasmine.createSpyObj 'mkdirp', ['sync']
      swig = jasmine.createSpyObj 'swig', ['compileFile']
      registryApi =
        getLatestTagForImage: -> q name: '14.04'
      config =
        servicesPath: '/tmp/services'

      swig.compileFile.andReturn ->
        'template contents'

      ServiceBuilder = proxyquire '../src/service-builder',
        'fs': fs
        'mkdirp': mkdirp
        'swig': swig

      service =
        description: 'App Server'
        name: 'app'
        config: {}

      builder = new ServiceBuilder registryApi, config
      builder.build service, 1
      .then ->
        expect(fs.writeFileSync).toHaveBeenCalledWith(
          "/tmp/services/app.v14-04.1.service", 'template contents'
        )
        expect(mkdirp.sync).toHaveBeenCalledWith '/tmp/services'

        done()
