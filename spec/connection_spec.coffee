Norm = require('../lib')

describe 'Norm.Connection', ->
  class StubClient
    constructor: ->
      @connected = false

    connect: ->
      @connected = true

  class StubDBAdapter
    constructor: (params) ->
      @client = new StubClient(params)

  Norm.Adapters.StubDBAdapter = StubDBAdapter

  beforeEach ->
    @.addMatchers
      toBeInstanceOf: (expected) ->
        @.actual instanceof expected

  describe 'default instance', ->
    beforeEach ->
      @.connection = new Norm.Connection { adapter: 'StubDBAdapter' }

    it 'is a connection', ->
      expect(@.connection).toBeInstanceOf(Norm.Connection)

    it 'has an adapter', ->
      expect(@.connection.adapter).toBeInstanceOf(StubDBAdapter)

    it 'is not connected', ->
      expect(@.connection.connected).toBeFalsy()

  describe 'connected instance', ->
    beforeEach ->
      @.connection = new Norm.Connection { adapter: 'StubDBAdapter' }
      @.connection.connect()

    it 'is connected', ->
      expect(@.connection.connected).toBeTruthy()