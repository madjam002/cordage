describe 'service', ->

  describe 'build', ->
    it 'should call the service builder', ->
      unitBuilder = jasmine.createSpyObj 'unitBuilder', ['build']

      Service = require '../src/service'

      service = new Service 'app',
        description: 'Super awesome application'

      registryApi = jasmine.createSpyObj 'registryApi', ['get']

      service.build unitBuilder, registryApi

      expect(unitBuilder.build).toHaveBeenCalledWith service, 1
