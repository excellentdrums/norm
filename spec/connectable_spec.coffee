Norm = require('../lib')

describe 'Norm.Connectable', ->
  class StubClient
    constructor: ->
      @connected = false

    connect: ->
      @connected = true

  class StubDBAdapter
    constructor: (params) ->
      @client = new StubClient(params)

  Norm.Adapters.StubDBAdapter = StubDBAdapter

  class Thing extends Norm.Mixable
    @extend Norm.Connectable

  beforeEach ->
    @.addMatchers
      toBeInstanceOf: (expected) ->
        @.actual instanceof expected

  describe 'before connection is established', ->
    it 'has no connection', ->
      expect(Thing.connection).toBeUndefined()

  describe 'after connection is established', ->
    beforeEach ->
      Thing.establishConnection { adapter: 'StubDBAdapter' }

      it 'sets a connection', ->
        expect(Thing.connection).toBeInstanceOf(Norm.Connection)

      it 'sets the connection adapter', ->
        expect(Thing.connection.adapter).toBeInstanceOf(StubDBAdapter)

      it 'has a connected client', ->
        expect(Thing.connection.adapter.client.connected).toBeTruthy()
