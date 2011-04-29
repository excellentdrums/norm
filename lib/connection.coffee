Postgres     = require 'pg'
EventEmitter = require('events').EventEmitter
adapters     = require './adapters'

class Connection extends EventEmitter
  constructor: (params) ->
    @params     = params
    @.adapter   = new adapters[params.adapter]
    @.connected = false

  connect: ->
    @.client = new Postgres.Client(@.params);
    if @.connected or @.doConnect()
      @.doOn();
      console.log 'Connected!'
    else
      console.log 'Connection Failed!'

  disconnect: ->
    if @.client.queryQueue.length is 0
      @.client.end()
    else
      @.client.on 'drain', @.client.end.bind(@.client)

  doConnect: ->
    @.client.connect()
    @.connected = true

  doOn: ->
    @.on 'query', (query, callback) =>
      @.client.query query, (err, result) =>
        callback(err, result)

    @.on 'insert', (criteria, callback) =>
      @.emit 'query', criteria.asInsert(), callback

    @.on 'select', (criteria, callback) =>
      @.emit 'query', criteria.asSelect(), callback

    @.on 'update', (criteria, callback) =>
      # update = @.adapter.update instance.tableName, options
      @.emit 'query', criteria.asUpdate(), callback

    @.on 'delete', (criteria, callback) =>
      @.emit 'query', criteria.asDelete(), callback

module.exports = Connection
