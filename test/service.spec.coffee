describe 'service', ->

  describe 'build', ->
    it 'should call the service builder', ->
      serviceBuilder = jasmine.createSpyObj 'serviceBuilder', ['build']

      Service = require '../src/service'

      service = new Service 'app',
        description: 'Super awesome application'

      registryApi = jasmine.createSpyObj 'registryApi', ['get']

      service.build serviceBuilder, registryApi

      expect(serviceBuilder.build).toHaveBeenCalledWith service, 1
