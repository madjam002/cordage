proxyquire = require 'proxyquire'
q = require 'q'

program = null
cordagefile = null
fleetctl = null
cliTable = null

describe 'cordage list', ->

  beforeEach ->
    program = require './mocks/program'

    cordagefile =
      read: -> q {}
      services: []

    fleetctl = jasmine.createSpyObj 'fleetctl', ['listUnits']
    cliTable = []

  it 'should list all of the services and units', (done) ->
    List = proxyquire '../src/list',
      './cordagefile': cordagefile
      './fleetctl': fleetctl
      'cli-table': -> cliTable

    list = new List program

    fleetctl.listUnits.andReturn q([
      { unit: 'test.v1.1.service', state: 'activated', active: 'running', ip: '127.0.0.1' }
      { unit: 'test.v1.2.service', state: 'activated', active: 'running', ip: '127.0.0.1' }
      { unit: 'test.v1.3.service', state: 'inactive', active: null, ip: null }
    ])

    cordagefile.services.push
      name: 'test'
      fileName: 'test.v1'
      config:
        description: 'Testing Service'

    list.run().then ->
      expect(cliTable).toContain [ 'test.v1.1', 'activated', 'running', '127.0.0.1' ]
      expect(cliTable).toContain [ 'test.v1.2', 'activated', 'running', '127.0.0.1' ]
      expect(cliTable).toContain [ 'test.v1.3', 'inactive', '-', '-' ]
      done()
