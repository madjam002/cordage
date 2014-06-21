describe 'service', ->

  describe 'build', ->
    it 'should call the service builder', ->
      unitBuilder = jasmine.createSpyObj 'unitBuilder', ['build']

      Service = require '../src/service'

      service = new Service 'app',
        description: 'Super awesome application'

      service.build unitBuilder

      expect(unitBuilder.build).toHaveBeenCalledWith service, 1
