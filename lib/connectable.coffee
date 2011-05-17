Configuration = require './configuration'
Connection    = require './connection'

module.exports = class Connectable
  @establishConnection: (params) ->
    @.connection = new Connection params
    @.connection.connect()

  @establishConnection Configuration.db
