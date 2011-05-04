Norm = require '../lib'

connectionParams =
  adapter:  'PostgresAdapter'
  user:     'jimmy'
  password: ''
  database: 'hooray'
  host:     'localhost'
  port:     5432

Norm.connect(connectionParams)

class Person extends Norm.Model
  @tableName: 'people'

deletedAll = false
Person.deleteAll (err, result) ->
  deletedAll = true

describe 'Model', ->
  prepared = -> deletedAll is true
  beforeEach ->
    @.addMatchers
      toBeInstanceOf: (expected) ->
        @.actual instanceof expected
    waitsFor prepared, 'preparation of test database', 100

  it 'is an instance of Model', ->
    expect(Person.prototype).toBeInstanceOf(Norm.Model)

  describe '.init', ->
    instance = null
    error    = null

    options =
      first_name: 'Jim'
      last_name:  'Drannbauer'
    Person.init options, (err, person) ->
      instance = person
      error    = err

    it 'initializes and returns a model instance', ->
      expect(instance).toBeInstanceOf(Person)

    it 'sets the given properties on the initialized model instance', ->
      expect(instance.get('first_name')).toEqual('Jim')
      expect(instance.get('last_name')).toEqual('Drannbauer')

    it 'does not define the id property on the initialized model instance', ->
      expect(instance.get('id')).not.toBeDefined()

    it 'does not define other properties on the initialized model instance', ->
      expect(instance.get('middle_name')).not.toBeDefined()
      expect(instance.get('age')).not.toBeDefined()

    it 'leaves unknown properties of the initialized model instance undefined', ->
      expect(instance.get('blarg')).not.toBeDefined()

  describe '.create', ->
    done    = -> created isnt null
    created = null
    error   = null

    options =
      first_name: 'Kerry'
      last_name:  'Drannbauer'
    Person.create options, (err, person) ->
      created = person
      error   = err

    beforeEach ->
      waitsFor done, 'model instance to be created', 100

    it 'creates and returns a model instance', ->
      expect(created).toBeInstanceOf(Person)

    it 'sets the given properties on the created model instance', ->
      expect(created.get('first_name')).toEqual('Kerry')
      expect(created.get('last_name')).toEqual('Drannbauer')

    it 'sets the id property on the created model instance', ->
      expect(created.get('id')).not.toBeNull()

    it 'sets the other properties on the created model instance to null', ->
      expect(created.get('middle_name')).toBeNull()
      expect(created.get('age')).toBeNull()

    it 'leaves unknown properties of the created model instance undefined', ->
      expect(created.get('blarg')).toBeUndefined()

  describe '.find', ->
    done    = -> found isnt null
    created = null
    found   = null
    error   = null

    options =
      first_name: 'Kyra'
      last_name:  'Drannbauer'
    Person.create options, (err, person) ->
      created = person
      Person.find person.get('id'), (err, person) ->
        found = person
        error = err

    beforeEach ->
      waitsFor done, 'model instance to be found', 100

    it 'finds and returns a model instance', ->
      expect(found).toBeInstanceOf(Person)

    it 'provides the properties of the found model instance', ->
      expect(found.get('first_name')).toEqual('Kyra')
      expect(found.get('last_name')).toEqual('Drannbauer')

    it 'provides the id property of the found model instance', ->
      expect(found.get('id')).not.toBeNull()
      expect(found.get('id')).toEqual(created.get('id'))

    it 'provides the null properties on the found model instance as null', ->
      expect(found.get('middle_name')).toBeNull()
      expect(found.get('age')).toBeNull()

    it 'leaves unknown properties of the found model instance undefined', ->
      expect(found.get('blarg')).toBeUndefined()

  describe '#save', ->
    done     = -> found isnt null
    instance = null
    saved    = null
    found    = null

    options =
      first_name: 'Dylan'
      last_name:  'Drannbauer'

    Person.init options, (err, person) ->
      instance = person
      person.save (err, person) ->
        saved = person
        Person.find person.get('id'), (err, person) ->
          found = person

    beforeEach ->
      waitsFor done, 'saved model instance to be found', 100

    it 'saves and returns a model instance', ->
      expect(saved).toBeInstanceOf(Person)

    it 'sets the given properties on the saved model instance', ->
      expect(saved.get('first_name')).toEqual('Dylan')
      expect(saved.get('last_name')).toEqual('Drannbauer')

    it 'sets the id property on the saved model instance', ->
      expect(saved.get('id')).not.toBeNull()

    it 'sets the other properties on the saved model instance to null', ->
      expect(saved.get('middle_name')).toBeNull()
      expect(saved.get('age')).toBeNull()

    it 'leaves unknown properties of the saved model instance undefined', ->
      expect(saved.get('blarg')).toBeUndefined()

    it 'was persisted', ->
      expect(found).toEqual(saved)

  describe '#updateAttributes', ->
    done    = -> found isnt null
    created = null
    updated = null
    found   = null

    origOptions =
      first_name: 'Declan'
      last_name:  'Drannbauer'
    updatedOptions =
      first_name: 'Ducklan'

    Person.create origOptions, (err, person) ->
      created = person
      person.updateAttributes updatedOptions, (err, person) ->
        updated = person
        Person.find person.get('id'), (err, person) ->
          found = person

    beforeEach ->
      waitsFor done, 'updated model instance to be found', 100

    it 'updates and returns a model instance', ->
      expect(updated).toBeInstanceOf(Person)

    it 'updates the given properties on the model instance', ->
      expect(updated.get('first_name')).toEqual('Ducklan')

    it 'leaves other properties on the model instance unchanged', ->
      expect(updated.get('last_name'))
        .toEqual(created.get('last_name'))
      expect(updated.get('id'))
        .toEqual(created.get('id'))

    it 'was persisted', ->
      expect(found).toEqual(updated)

  describe '.all', ->
    done = -> all isnt null
    all = null

    Person.all (err, people) ->
      all = people

    beforeEach ->
      waitsFor done, 'all people to be found', 100

    it 'returns all people', ->
      expect(all).toBeInstanceOf(Array)
