Service = require '../src/service'

describe 'service', ->

  it 'should should set config options on the service instance', ->
    service = new Service 'app',
      minUnits: 2

    expect(service.minUnits).toBe 2

  describe 'unitCount', ->
    it 'should return the minimum units if there is no unit count specified', ->
      service = new Service 'app',
        minUnits: 3

      expect(service.unitCount).toBe 3

    it 'should return the minimum units of the specified unit count is below the minimum', ->
      service = new Service 'app',
        minUnits: 2

      service.unitCount = 1
      expect(service.unitCount).toBe 2

    it 'should return the specified unit count is it is greater than the minimum units', ->
      service = new Service 'app',
        minUnits: 2

      service.unitCount = 3
      expect(service.unitCount).toBe 3

  describe 'build', ->
    it 'should call the service builder', ->
      unitBuilder = jasmine.createSpyObj 'unitBuilder', ['build']

      service = new Service 'app',
        description: 'Super awesome application'

      service.build unitBuilder, '14.04'

      expect(unitBuilder.build).toHaveBeenCalledWith service, '14.04', 1

  describe 'parseName', ->
    it 'should return just the name if no version is specified', ->
      expect(Service.parseName 'app').toEqual
        name: 'app'

    it 'should return just the name and version if a version is specified', ->
      expect(Service.parseName 'app:14.04').toEqual
        name: 'app'
        version: '14.04'
