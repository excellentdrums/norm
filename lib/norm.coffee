Model      = require './model'
Connection = require './connection'
Adapters   = require './adapters'

class Norm
  @Model:    Model
  @Adapters: Adapters
  @connect: (params) ->
    @Model.connection = new Connection params
    @Model.connection.connect()

module.exports = Norm
