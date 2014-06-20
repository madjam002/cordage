proxyquire = require 'proxyquire'
q = require 'q'

program = null
cordagefile = null
fleetctl = null

describe 'cordage destroy', ->

  beforeEach ->
    program = require './mocks/program'

    cordagefile =
      read: -> q {}
      services: []

    fleetctl = jasmine.createSpyObj 'fleetctl', ['listUnits', 'destroy']

  it 'should destroy any units associated with the given service', (done) ->
    Destroy = proxyquire '../src/destroy',
      './cordagefile': cordagefile
      './fleetctl': fleetctl

    destroy = new Destroy program

    fleetctl.listUnits.andReturn q([
      { unit: 'test.v1.1.service', state: 'activated', active: 'running', ip: '127.0.0.1' }
      { unit: 'app.v1.1.service', state: 'activated', active: 'failed', ip: '127.0.0.2' }
    ])

    cordagefile.services.push
      name: 'app'
      fileName: 'app.v1'
      filePath: '/services/app.v1.*.service'
      config:
        description: 'Application Service'

    destroy.run('app', force: true).then ->
      expect(fleetctl.destroy).toHaveBeenCalledWith 'app.v1.1.service'
      expect(fleetctl.destroy.calls.length).toBe 1

      done()

  it 'should throw an error if the service doesn\'t exist', (done) ->
    Destroy = proxyquire '../src/destroy',
      './cordagefile': cordagefile
      './fleetctl': fleetctl

    destroy = new Destroy program

    cordagefile.services.push
      name: 'app'

    destroy.run('database', force: true).then ->
      expect(fleetctl.destroy).not.toHaveBeenCalled()
      done()
