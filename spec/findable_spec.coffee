Norm = require('../lib')

class StubCriteria
  constructor: (@err = 'some err', @result = {}) ->
  limit: -> null
  emit: (event, callback) ->
    callback(@err, @result)

class Thing extends Norm.Mixable
  @mixin Norm.Findable
  @where:  -> null
  @create: -> null
  @init:   -> null

describe 'Norm.Findable', ->
  beforeEach ->
    @.addMatchers
      toBeInstanceOf: (expected) ->
        @.actual instanceof expected

  describe '.find', ->
    beforeEach ->
      @criteria = new StubCriteria
      @callback = jasmine.createSpy('Callback')
      spyOn(@criteria, 'limit').andReturn(@criteria)
      spyOn(@criteria, 'emit').andCallThrough()
      spyOn(Thing, 'where').andReturn(@criteria)

    it 'adds a where criteria', ->
      Thing.find('some_id', @callback)
      expect(Thing.where).toHaveBeenCalledWith( { id: 'some_id' } )

    it 'adds a limit criteria', ->
      Thing.find('some_id', @callback)
      expect(@criteria.limit).toHaveBeenCalledWith(1)

    it 'emits the criteria', ->
      Thing.find('some_id', @callback)
      expect(@criteria.emit).toHaveBeenCalled()

    describe 'when result has no rows', ->
      it 'calls back with the err and null', ->
        @criteria.result = { rowCount: 0 }
        Thing.find('some_id', @callback)
        expect(@callback).toHaveBeenCalledWith('some err', null)

    describe 'when result has one row', ->
      it 'calls back with the err and a new instance of Thing for the row', ->
        @criteria.result = { rowCount: 1, rows: ['some result']}
        Thing.find('some_id', @callback)
        expect(@callback).toHaveBeenCalledWith('some err', new Thing 'some result')

    describe 'when result has more than one row', ->
      it 'calls back with the err and a new instance of Thing for the first row', ->
        @criteria.result = { rowCount: 1, rows: ['first result', 'second result']}
        Thing.find('some_id', @callback)
        expect(@callback).toHaveBeenCalledWith('some err', new Thing 'first result')

  describe '.findOrCreateBy', ->
    beforeEach ->
      @criteria = new StubCriteria
      @callback = jasmine.createSpy('Callback')
      spyOn(@criteria, 'limit').andReturn(@criteria)
      spyOn(@criteria, 'emit').andCallThrough()
      spyOn(Thing, 'where').andReturn(@criteria)
      spyOn(Thing, 'create')
      spyOn(Thing, 'init')

    it 'adds a where criteria', ->
      Thing.findOrCreateBy({ some: 'attributes' }, @callback)
      expect(Thing.where).toHaveBeenCalledWith( { some: 'attributes' } )

    it 'adds a limit criteria', ->
      Thing.findOrCreateBy({ some: 'attributes' }, @callback)
      expect(@criteria.limit).toHaveBeenCalledWith(1)

    it 'emits the criteria', ->
      Thing.find('some_id', @callback)
      expect(@criteria.emit).toHaveBeenCalled()

    describe 'when result has no rows', ->
      it 'creates a Thing with the attributes and the callback', ->
        @criteria.result = { rowCount: 0 }
        Thing.findOrCreateBy({ some: 'attributes' }, @callback)
        expect(Thing.create).toHaveBeenCalledWith({ some: 'attributes' }, @callback)

    describe 'when result has one row', ->
      it 'inits a Thing with the result and the callback', ->
        @criteria.result = { rowCount: 1, rows: ['some result']}
        Thing.findOrCreateBy({ some: 'attributes' }, @callback)
        expect(Thing.init).toHaveBeenCalledWith('some result', @callback)

    describe 'when result has more than one row', ->
      it 'inits a Thing with the first result and the callback', ->
        @criteria.result = { rowCount: 1, rows: ['first result', 'second result']}
        Thing.findOrCreateBy({ some: 'attributes' }, @callback)
        expect(Thing.init).toHaveBeenCalledWith('first result', @callback)

  describe '.findOrInitializeBy', ->
    beforeEach ->
      @criteria = new StubCriteria
      @callback = jasmine.createSpy('Callback')
      spyOn(@criteria, 'limit').andReturn(@criteria)
      spyOn(@criteria, 'emit').andCallThrough()
      spyOn(Thing, 'where').andReturn(@criteria)
      spyOn(Thing, 'init')

    it 'adds a where criteria', ->
      Thing.findOrInitializeBy({ some: 'attributes' }, @callback)
      expect(Thing.where).toHaveBeenCalledWith( { some: 'attributes' } )

    it 'adds a limit criteria', ->
      Thing.findOrInitializeBy({ some: 'attributes' }, @callback)
      expect(@criteria.limit).toHaveBeenCalledWith(1)

    it 'emits the criteria', ->
      Thing.find('some_id', @callback)
      expect(@criteria.emit).toHaveBeenCalled()

    describe 'when result has no rows', ->
      it 'inits a Thing with the attributes and the callback', ->
        @criteria.result = { rowCount: 0 }
        Thing.findOrInitializeBy({ some: 'attributes' }, @callback)
        expect(Thing.init).toHaveBeenCalledWith({ some: 'attributes' }, @callback)

    describe 'when result has one row', ->
      it 'inits a Thing with the result and the callback', ->
        @criteria.result = { rowCount: 1, rows: ['some result']}
        Thing.findOrInitializeBy({ some: 'attributes' }, @callback)
        expect(Thing.init).toHaveBeenCalledWith('some result', @callback)

    describe 'when result has more than one row', ->
      it 'inits a Thing with the first result and the callback', ->
        @criteria.result = { rowCount: 1, rows: ['first result', 'second result']}
        Thing.findOrInitializeBy({ some: 'attributes' }, @callback)
        expect(Thing.init).toHaveBeenCalledWith('first result', @callback)
