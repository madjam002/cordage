proxyquire = require 'proxyquire'
q = require 'q'

Unit = require '../src/unit'

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
      new Unit 'test.v14-04.1.service', state: 'activated', active: 'running', ip: '127.0.0.1'
      new Unit 'app.v14-04.1.service', state: 'activated', active: 'failed', ip: '127.0.0.2'
    ])

    cordagefile.services.push
      name: 'app'
      config:
        description: 'Application Service'

    destroy.run('app', force: true).then ->
      expect(fleetctl.destroy).toHaveBeenCalledWith 'app.v14-04.1.service'
      expect(fleetctl.destroy.calls.length).toBe 1

      done()

  it 'should destroy any units associated with a specific version of the given service', (done) ->
    Destroy = proxyquire '../src/destroy',
      './cordagefile': cordagefile
      './fleetctl': fleetctl

    destroy = new Destroy program

    fleetctl.listUnits.andReturn q([
      new Unit 'test.v14-04.1.service', state: 'activated', active: 'running', ip: '127.0.0.1'
      new Unit 'test.v14-04.1.service', state: 'activated', active: 'running', ip: '127.0.0.1'
      new Unit 'app.v12-04.1.service', state: 'activated', active: 'failed', ip: '127.0.0.2'
      new Unit 'app.v12-04.2.service', state: 'activated', active: 'failed', ip: '127.0.0.2'
      new Unit 'app.v14-04.1.service', state: 'activated', active: 'failed', ip: '127.0.0.2'
      new Unit 'app.v14-04.2.service', state: 'activated', active: 'failed', ip: '127.0.0.2'
      new Unit 'app.v14-04.3.service', state: 'activated', active: 'failed', ip: '127.0.0.2'
    ])

    cordagefile.services.push
      name: 'app'
      config:
        description: 'Application Service'

    destroy.run('app:14.04', force: true).then ->
      expect(fleetctl.destroy).toHaveBeenCalledWith 'app.v14-04.1.service'
      expect(fleetctl.destroy).toHaveBeenCalledWith 'app.v14-04.2.service'
      expect(fleetctl.destroy).toHaveBeenCalledWith 'app.v14-04.3.service'
      expect(fleetctl.destroy.calls.length).toBe 3

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
