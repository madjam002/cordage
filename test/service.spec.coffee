describe 'service', ->

  describe 'build', ->
    it 'should call the service builder', ->
      serviceBuilder = require '../src/service-builder'
      Service = require.requireActual '../src/service'

      service = new Service 'app',
        description: 'Super awesome application'

      service.build()

      expect(serviceBuilder).toBeCalledWith 'app',
        description: 'Super awesome application'
