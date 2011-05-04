EventEmitter = require('events').EventEmitter
adapters     = require './adapters'

module.exports = class Connection extends EventEmitter
  constructor: (params) ->
    @adapter   = new adapters[params.adapter](params)
    @connected = false

    @on 'insert', (criteria, callback) =>
      @adapter.emit 'query', criteria.asInsert(), callback

    @on 'select', (criteria, callback) =>
      @adapter.emit 'query', criteria.asSelect(), callback

    @on 'update', (criteria, callback) =>
      @adapter.emit 'query', criteria.asUpdate(), callback

    @on 'delete', (criteria, callback) =>
      @adapter.emit 'query', criteria.asDelete(), callback

  connect: ->
    if @connected or @doConnect()
      console.log 'Connected!'
    else
      console.log 'Connection Failed!'

  disconnect: ->
    if @adapter.client.queryQueue.length is 0
      @adapter.client.end()
    else
      @adapter.client.on 'drain', @adapter.client.end.bind(@client)

  doConnect: ->
    @adapter.client.connect()
    @connected = true
