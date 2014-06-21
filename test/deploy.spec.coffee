proxyquire = require 'proxyquire'
q = require 'q'

Service = require '../src/service'
Unit = require '../src/unit'

program = null
cordagefile = null
fleetctl = null
unitBuilder = null

describe 'cordage deploy', ->

  beforeEach ->
    program = require './mocks/program'

    cordagefile =
      read: -> q {}
      services: []

    fleetctl = jasmine.createSpyObj 'fleetctl', ['submit', 'start', 'listUnits']
    unitBuilder = jasmine.createSpyObj 'unitBuilder', ['build']

  it 'should build service files and then submit and start them using fleet', (done) ->
    Deploy = proxyquire '../src/deploy',
      './cordagefile': cordagefile
      './fleetctl': fleetctl
      './unit-builder': -> unitBuilder

    deploy = new Deploy program

    fleetctl.listUnits.andReturn q([])

    test = new Service 'test', description: 'Testing Service'
    cordagefile.services.push test

    app = new Service 'app', description: 'Application Service', minUnits: 2
    cordagefile.services.push app

    units = [
      new Unit '/services/test.v0-0-1.1.service'
      new Unit '/services/app.v0-0-1.1.service'
      new Unit '/services/app.v0-0-1.2.service'
    ]
    currentUnit = 0
    unitBuilder.build.andCallFake -> q(units[currentUnit++])

    deploy.run().then ->
      expect(fleetctl.submit).toHaveBeenCalledWith '/services/test.v0-0-1.1.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/test.v0-0-1.1.service'

      expect(fleetctl.submit).toHaveBeenCalledWith '/services/app.v0-0-1.1.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/app.v0-0-1.1.service'

      expect(fleetctl.submit).toHaveBeenCalledWith '/services/app.v0-0-1.2.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/app.v0-0-1.2.service'

      expect(fleetctl.submit.calls.length).toBe 3
      expect(fleetctl.start.calls.length).toBe 3

      done()

  it 'should deploy the same amount of units as the old version when deploying a new version', (done) ->
    Deploy = proxyquire '../src/deploy',
      './cordagefile': cordagefile
      './fleetctl': fleetctl
      './unit-builder': -> unitBuilder

    deploy = new Deploy program

    fleetctl.listUnits.andReturn q([
      { unit: 'app.v0-0-1.1.service', state: 'activated', active: 'running', ip: '127.0.0.1' }
      { unit: 'app.v0-0-1.2.service', state: 'activated', active: 'running', ip: '127.0.0.2' }
    ])

    app = new Service 'app', description: 'Application Service'
    cordagefile.services.push app

    units = [
      new Unit '/services/app.v0-0-2.1.service'
      new Unit '/services/app.v0-0-2.2.service'
    ]
    currentUnit = 0
    unitBuilder.build.andCallFake -> q(units[currentUnit++])

    deploy.run().then ->
      expect(fleetctl.submit).toHaveBeenCalledWith '/services/app.v0-0-2.1.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/app.v0-0-2.1.service'

      expect(fleetctl.submit).toHaveBeenCalledWith '/services/app.v0-0-2.2.service'
      expect(fleetctl.start).toHaveBeenCalledWith '/services/app.v0-0-2.2.service'

      expect(fleetctl.submit.calls.length).toBe 2
      expect(fleetctl.start.calls.length).toBe 2

      done()
