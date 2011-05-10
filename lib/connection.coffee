EventEmitter = require('events').EventEmitter
Adapters     = require './adapters'

module.exports = class Connection extends EventEmitter
  constructor: (params) ->
    @adapter   = new Adapters[params.adapter](params)
    @connected = false

  connect: ->
    if @connected or @doConnect()
      console.log 'Connected with ' + @adapter.constructor.name + '!'
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
