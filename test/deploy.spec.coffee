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
      fileName: 'test.v0-0-1'
      config:
        description: 'Testing Service'
      units: [
        '/services/test.v0-0-1.1.service'
      ]
      build: buildCallback

    cordagefile.services.push
      name: 'app'
      fileName: 'app.v0-0-1'
      config:
        description: 'Application Service'
      units: [
        '/services/app.v0-0-1.1.service'
        '/services/app.v0-0-1.2.service'
      ]
      build: buildCallback

    deploy.run().then ->
      expect(buildCallback).toHaveBeenCalled()

      expect(fleetctl.submit).toHaveBeenCalledWith '/services/test.v0-0-1.1.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/test.v0-0-1.1.service'

      expect(fleetctl.submit).toHaveBeenCalledWith '/services/app.v0-0-1.1.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/app.v0-0-1.1.service'

      expect(fleetctl.submit).toHaveBeenCalledWith '/services/app.v0-0-1.2.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/app.v0-0-1.2.service'

      expect(fleetctl.submit.calls.length).toBe 3
      expect(fleetctl.start.calls.length).toBe 3

      done()
