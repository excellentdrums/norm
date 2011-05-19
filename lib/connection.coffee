EventEmitter = require('events').EventEmitter
Adapters     = require './adapters'

module.exports = class Connection extends EventEmitter
  constructor: (params) ->
    @adapter   = new Adapters[params.adapter](params)
    @connected = false

  connect: ->
    @connected or @doConnect() or console.log 'Connection Failed!'

  doConnect: ->
    @adapter.client.connect()
    @connected = true
