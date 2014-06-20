proxyquire = require 'proxyquire'

describe 'service', ->

  describe 'build', ->
    it 'should call the service builder', ->
      serviceBuilder = jasmine.createSpy 'serviceBuilder'

      Service = proxyquire '../src/service',
        './service-builder': serviceBuilder

      service = new Service 'app',
        description: 'Super awesome application'

      service.build()

      expect(serviceBuilder).toHaveBeenCalledWith service, 1
