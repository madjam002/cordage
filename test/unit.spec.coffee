Unit = require '../src/unit'
Service = require '../src/service'

describe 'unit', ->

  it 'should parse the name passed to the constructor', ->
    unit = new Unit 'app.v14-04.1'

    expect(unit.serviceName).toBe 'app'
    expect(unit.version).toBe '14-04'
    expect(unit.instance).toBe 1
    expect(unit.path).toBeUndefined()

  it 'should parse the state passed to the constructor', ->
    unit = new Unit 'app.v14-04.1',
      state: 'active'
      active: 'running'
      ip: '127.0.0.1'

    expect(unit.state).toBe 'active'
    expect(unit.active).toBe 'running'
    expect(unit.ip).toBe '127.0.0.1'

  it 'should parse the path passed to the constructor', ->
    unit = new Unit './.cordage/services/app.v14-04.1.service'

    expect(unit.serviceName).toBe 'app'
    expect(unit.version).toBe '14-04'
    expect(unit.instance).toBe 1
    expect(unit.path).toBe './.cordage/services/app.v14-04.1.service'

  describe 'belongsTo', ->
    it 'should return true if the unit belongs to the given service', ->
      unit = new Unit 'app.v14-04.1'
      service = new Service 'app'

      expect(unit.belongsTo service).toBe true

    it 'should return false if the unit doesn\'t belong to the given service', ->
      unit = new Unit 'app.v14-04.1'
      service = new Service 'worker'

      expect(unit.belongsTo service).toBe false

  describe 'isVersion', ->
    it 'should return true if the unit is the same version as the given version', ->
      unit = new Unit 'app.v14-04.1'

      expect(unit.isVersion '14.04').toBe true

    it 'should return false if the unit isn\'t the same version as the given version', ->
      unit = new Unit 'app.v12-04.1'

      expect(unit.isVersion '14.04').toBe false
