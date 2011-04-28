Model      = require './model'
Connection = require './connection'
Adapters   = require './adapters'
Criteria   = require './criteria'

class Norm
  @Model:    Model
  @Adapters: Adapters
  @Criteria: Criteria
  @connect: (params) ->
    @Model.connection = new Connection params
    @Model.connection.connect()

module.exports = Norm
