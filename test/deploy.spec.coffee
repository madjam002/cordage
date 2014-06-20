proxyquire = require 'proxyquire'
q = require 'q'

program = null
cordagefile = null
fleetctl = null

describe 'cordage deploy', ->

  beforeEach ->
    program = require './mocks/program'

    cordagefile =
      read: -> q {}
      services: []

    fleetctl = jasmine.createSpyObj 'fleetctl', ['submit', 'start']

  it 'should build service files and then submit and start them using fleet', (done) ->
    Deploy = proxyquire '../src/deploy',
      './cordagefile': cordagefile
      './fleetctl': fleetctl

    deploy = new Deploy program

    buildCallback = jasmine.createSpy 'build'

    cordagefile.services.push
      name: 'test'
      fileName: 'test.v1'
      filePath: '/services/test.v1.*.service'
      config:
        description: 'Testing Service'
      build: buildCallback

    cordagefile.services.push
      name: 'app'
      fileName: 'app.v1'
      filePath: '/services/app.v1.*.service'
      config:
        description: 'Application Service'
      build: buildCallback

    deploy.run().then ->
      expect(buildCallback).toHaveBeenCalled()

      expect(fleetctl.submit).toHaveBeenCalledWith [
        '/services/test.v1.*.service'
        '/services/app.v1.*.service'
      ]
      expect(fleetctl.start).toHaveBeenCalledWith '/services/test.v1.*.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/app.v1.*.service'

      done()
