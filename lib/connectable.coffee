Configuration = require './configuration'
Connection    = require './connection'
Criteria      = require './criteria'

module.exports = class Connectable
  @establishConnection: (params) ->
    @connection = new Connection params
    @connection.connect()

  @establishConnection Configuration.db
