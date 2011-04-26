Norm = require '../lib'

vows   = require 'vows'
assert = require 'assert'
eyes   = require 'eyes'

connectionParams =
  adapter:  'PostgresAdapter'
  user:     'jimmy'
  password: ''
  database: 'hooray'
  host:     'localhost'
  port:     5432

Norm.connect(connectionParams);

class Person extends Norm.Model
  @tableName: 'people'

suite = vows.describe 'Norm'

suite.addBatch
  'Model.deleteAll':
    topic: ->
      Person.deleteAll @.callback; return

    'returns the number of rows deleted': (err, result) ->
      assert.typeOf result, 'number'

    'deletes zero or more rows': (err, result) ->
      assert.isTrue result >= 0

.addBatch
  'Model.init':
    topic: ->
      options =
        first_name: 'Jim'
        last_name:  'Drannbauer'
      Person.init options, @.callback; return

    'initializes and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'sets the given properties on the initialized model instance': (err, person) ->
      assert.equal person.get('first_name'), 'Jim'
      assert.equal person.get('last_name'), 'Drannbauer'

    'does not define the id property on the initialized model instance': (err, person) ->
      assert.isUndefined person.get('id')

    'does not define other properties on the initialized model instance': (err, person) ->
      assert.isUndefined person.get('middle_name')
      assert.isUndefined person.get('age')

    'leaves unknown properties of the initialized model instance undefined': (err, person) ->
      assert.isUndefined person.get('blarg')

.addBatch
  'Model.create':
    topic: ->
      options =
        first_name: 'Kerry'
        last_name:  'Drannbauer'
      Person.create options, @.callback; return

    'creates and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'sets the given properties on the created model instance': (err, person) ->
      assert.equal person.get('first_name'), 'Kerry'
      assert.equal person.get('last_name'), 'Drannbauer'

    'sets the id property on the created model instance': (err, person) ->
      assert.isNotNull person.get('id')

    'sets the other properties on the created model instance to null': (err, person) ->
      assert.isNull person.get('middle_name')
      assert.isNull person.get('age')

    'leaves unknown properties of the created model instance undefined': (err, person) ->
      assert.isUndefined person.get('blarg')

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.create multiple models':
    topic: ->
      people = [
        { first_name: 'Kerry', last_name: 'Drannbauer' }
        { first_name: 'Jim',   last_name: 'Drannbauer' }
      ]

      Person.create people, @.callback; return

    'creates and returns an array of model instances': (err, people) ->
      assert.instanceOf people, Array

    'sets the given properties on each of the created model instances': (err, people) ->
      assert.equal people[0].get('first_name'), 'Kerry'
      assert.equal people[0].get('last_name'), 'Drannbauer'
      assert.equal people[1].get('first_name'), 'Jim'
      assert.equal people[1].get('last_name'), 'Drannbauer'

    'sets the id property on the created model instances': (err, people) ->
      assert.isNotNull people[0].get('id')
      assert.isNotNull people[1].get('id')

    'sets the other properties on the created model instances to null': (err, people) ->
      assert.isNull people[0].get('middle_name')
      assert.isNull people[0].get('age')
      assert.isNull people[1].get('middle_name')
      assert.isNull people[1].get('age')

    'leaves unknown properties of the created model instances undefined': (err, people) ->
      assert.isUndefined people[0].get('blarg')
      assert.isUndefined people[1].get('blarg')

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.find':
    topic: ->
      options =
        first_name: 'Kyra'
        last_name:  'Drannbauer'
      Person.create options, (err, person) =>
        @.created = person
        Person.find person.get('id'), @.callback; return
      return

    'finds and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'provides the properties of the found model instance': (err, person) ->
      assert.equal person.get('first_name'), 'Kyra'
      assert.equal person.get('last_name'), 'Drannbauer'

    'provides the id property of the found model instance': (err, person) ->
      assert.isNotNull person.get('id')
      assert.equal person.get('id'), @.created.get('id')

    'provides the null properties on the found model instance as null': (err, person) ->
      assert.isNull person.get('middle_name')
      assert.isNull person.get('age')

    'leaves unknown properties of the found model instance undefined': (err, person) ->
      assert.isUndefined person.get('blarg')

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model#save':
    topic: ->
      options =
        first_name: 'Dylan'
        last_name:  'Drannbauer'

      Person.init options, (err, person) =>
        person.save @.callback; return
      return

    'saves and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'sets the given properties on the saved model instance': (err, person) ->
      assert.equal person.get('first_name'), 'Dylan'
      assert.equal person.get('last_name'), 'Drannbauer'

    'sets the id property on the saved model instance': (err, person) ->
      assert.isNotNull person.get('id')

    'sets the other properties on the saved model instance to null': (err, person) ->
      assert.isNull person.get('middle_name')
      assert.isNull person.get('age')

    'leaves unknown properties of the saved model instance undefined': (err, person) ->
      assert.isUndefined person.get('blarg')

    'persists the model instance':
      topic: (person) ->
        @.saved = person
        Person.find person.get('id'), @.callback; return
      'and can be found': (err, person) ->
        assert.deepEqual person, @.saved

    teardown: ->
      Person.deleteAll (err, result) ->
        assert.equal result, 1

.addBatch
  'Model#updateAttributes':
    topic: ->
      origOptions =
        first_name: 'Declan'
        last_name:  'Drannbauer'
      updatedOptions =
        first_name: 'Ducklan'

      Person.create origOptions, (err, person) =>
        @.created = person
        person.updateAttributes updatedOptions, @.callback; return
      return

    'updates and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'updates the given properties on the model instance': (err, person) ->
      assert.equal person.get('first_name'), 'Ducklan'

    'leaves other properties on the model instance unchanged': (err, person) ->
      assert.equal person.get('last_name'), @.created.get('last_name')
      assert.equal person.get('id'), @.created.get('id')

    'leaves other properties on the updated model instance null': (err, person) ->
      assert.isNull person.get('middle_name')
      assert.isNull person.get('age')

    'leaves unknown properties of the updated model instance undefined': (err, person) ->
      assert.isUndefined person.get('blarg')

    'persists the updated model instance':
      topic: (updated) ->
        @.updated = updated
        Person.find updated.get('id'), @.callback; return

      'and can be found': (err, person) ->
        assert.deepEqual person, @.updated

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.all with no options':
    topic: ->
      kerry =
        first_name: 'Kerry'
        last_name:  'Drannbauer'
      jim =
        first_name: 'Jim'
        last_name:  'Drannbauer'

      Person.create kerry, (err, person) =>
        @.kerry = person

      Person.create jim, (err, person) =>
        @.jim = person

      Person.all @.callback; return

    'returns an array of all people': (err, people) ->
      assert.instanceOf people, Array

    'can be counted': (err, people) ->
      assert.length people, 2

    'contains the people that have been persisted': (err, people) ->
      assert.deepInclude people, @.kerry
      assert.deepInclude people, @.jim

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.all with options':
    topic: ->
      kerry =
        first_name: 'Kerry'
        last_name:  'Drannbauer'
      jim =
        first_name: 'Jim'
        last_name:  'Drannbauer'

      Person.create kerry, (err, person) =>
        @.kerry = person

      Person.create jim, (err, person) =>
        @.jim = person

      options =
        where:
          first_name: 'Kerry'
      Person.all options, @.callback; return

    'returns an array of all people meet given criteria': (err, people) ->
      assert.instanceOf people, Array

    'can be counted': (err, people) ->
      assert.length people, 1

    'contains only the people that meet given criteria': (err, people) ->
      assert.deepInclude people, @.kerry
      _(people).each (person) => assert.notDeepEqual person, @.jim

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.count with no options':
    topic: ->
      kerry =
        first_name: 'Kerry'
        last_name:  'Drannbauer'
      jim =
        first_name: 'Jim'
        last_name:  'Drannbauer'

      Person.create kerry, (err, person) =>
        return

      Person.create jim, (err, person) =>
        return

      Person.count @.callback; return

    'returns a number': (err, result) ->
      assert.isNumber result

    'returns the count of all people': (err, result) ->
      assert.equal result, 2

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.count with options':
    topic: ->
      kerry =
        first_name: 'Kerry'
        last_name:  'Drannbauer'
      jim =
        first_name: 'Jim'
        last_name:  'Drannbauer'

      Person.create kerry, (err, person) =>
        return

      Person.create jim, (err, person) =>
        return

      options =
        where:
          first_name: 'Kerry'
      Person.count options, @.callback; return

    'returns a number': (err, result) ->
      assert.isNumber result

    'returns the count of all people that meet criteria': (err, result) ->
      assert.equal result, 1

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.exists when it does':
    topic: ->
      kyra =
        first_name: 'Kyra'
        last_name:  'Drannbauer'

      Person.create kyra, (err, person) =>
        @.kyra = person

      options =
        where:
          first_name: 'Kyra'

      Person.exists options, @.callback; return

    'returns true': (err, result) ->
      assert.isTrue result

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.exists when it does not':
    topic: ->
      options =
        where:
          first_name: 'Kyra'

      Person.exists options, @.callback; return

    'returns false': (err, result) ->
      assert.isFalse result

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.findOrCreateBy when created':
    topic: ->
      options =
        first_name: 'Dylan'
        last_name:  'Drannbauer'
      Person.findOrCreateBy options, @.callback; return

    'creates and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'sets the given properties on the created model instance': (err, person) ->
      assert.equal person.get('first_name'), 'Dylan'
      assert.equal person.get('last_name'), 'Drannbauer'

    'sets the id property on the created model instance': (err, person) ->
      assert.isNotNull person.get('id')

    'sets the other properties on the created model instance to null': (err, person) ->
      assert.isNull person.get('middle_name')
      assert.isNull person.get('age')

    'leaves unknown properties of the created model instance undefined': (err, person) ->
      assert.isUndefined person.get('blarg')

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.findOrCreateBy when found':
    topic: ->
      options =
        first_name: 'Declan'
        last_name:  'Drannbauer'

      Person.create options, (err, person) =>
        @.declan = person

      Person.findOrCreateBy options, @.callback; return

    'finds and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'is the same as the existing model': (err, person) ->
      assert.deepEqual person, @.declan

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.findOrInitializeBy when initialized':
    topic: ->
      options =
        first_name: 'Dylan'
        last_name:  'Drannbauer'
      Person.findOrInitializeBy options, @.callback; return

    'initializes and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'sets the given properties on the initialized model instance': (err, person) ->
      assert.equal person.get('first_name'), 'Dylan'
      assert.equal person.get('last_name'), 'Drannbauer'

    'does not define the id property on the initialized model instance': (err, person) ->
      assert.isUndefined person.get('id')

    'does not define other properties on the initialized model instance': (err, person) ->
      assert.isUndefined person.get('middle_name')
      assert.isUndefined person.get('age')

    'leaves unknown properties of the initialized model instance undefined': (err, person) ->
      assert.isUndefined person.get('blarg')

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.findOrInitializeBy when found':
    topic: ->
      options =
        first_name: 'Declan'
        last_name:  'Drannbauer'

      Person.create options, (err, person) =>
        @.declan = person

      Person.findOrInitializeBy options, @.callback; return

    'finds and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'is the same as the existing model': (err, person) ->
      assert.deepEqual person, @.declan

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.first with options':
    topic: ->
      kerry =
        first_name: 'Kerry'
        last_name:  'Drannbauer'
      firstJim =
        first_name: 'Jim'
        last_name:  'Drann'
      secondJim =
        first_name: 'Jim'
        last_name:  'Bauer'

      Person.create kerry, (err, person) =>
        @.kerry = person

      Person.create firstJim, (err, person) =>
        @.firstJim = person

      Person.create secondJim, (err, person) =>
        @.secondJim = person

      options =
        where:
          first_name: 'Jim'
      Person.first options, @.callback; return

    'finds and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'finds the first model instance that meets criteria': (err, person) ->
      assert.deepEqual person, @.firstJim

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.first with no options':
    topic: ->
      kerry =
        first_name: 'Kerry'
        last_name:  'Drannbauer'
      jim =
        first_name: 'Jim'
        last_name:  'Drannbauer'

      Person.create kerry, (err, person) =>
        @.kerry = person

      Person.create jim, (err, person) =>
        @.jim = person

      Person.first @.callback; return

    'finds and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'finds the first model instance': (err, person) ->
      assert.deepEqual person, @.kerry

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.last with options':
    topic: ->
      firstJim =
        first_name: 'Jim'
        last_name:  'Drann'
      secondJim =
        first_name: 'Jim'
        last_name:  'Bauer'
      kerry =
        first_name: 'Kerry'
        last_name:  'Drannbauer'

      Person.create firstJim, (err, person) =>
        @.firstJim = person

      Person.create secondJim, (err, person) =>
        @.secondJim = person

      Person.create kerry, (err, person) =>
        @.kerry = person

      options =
        where:
          first_name: 'Jim'
      Person.last options, @.callback; return

    'finds and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'finds the last model instance that meets criteria': (err, person) ->
      assert.deepEqual person, @.secondJim

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.addBatch
  'Model.last with no options':
    topic: ->
      kerry =
        first_name: 'Kerry'
        last_name:  'Drannbauer'
      jim =
        first_name: 'Jim'
        last_name:  'Drannbauer'

      Person.create jim, (err, person) =>
        @.jim = person

      Person.create kerry, (err, person) =>
        @.kerry = person

      Person.last @.callback; return

    'finds and returns a model instance': (err, person) ->
      assert.instanceOf person, Person

    'finds the last model instance': (err, person) ->
      assert.deepEqual person, @.kerry

    teardown: ->
      Person.deleteAll (err, result) ->
        return

.export(module)
