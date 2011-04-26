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

    @.on 'insert', (instance, callback) =>
      insert = @.adapter.insert instance
      @.emit 'query', insert, callback

    @.on 'select', (klass, options, callback) =>
      select = @.adapter.select klass.tableName, options
      @.emit 'query', select, callback

    @.on 'update', (instance, options, callback) =>
      update = @.adapter.update instance.tableName, options
      @.emit 'query', update, callback

    @.on 'delete', (instance, options, callback) =>
      del = @.adapter.delete instance.tableName, options
      @.emit 'query', del, callback

module.exports = Connection
