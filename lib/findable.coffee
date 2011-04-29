Criteria = require './criteria'

class Findable
  @find: (id, callback) ->
    criteria = @.where({id: id}).limit(1)
    @.connection.emit 'select', criteria, (err, result) =>
      callback err, new @ result.rows[0]

  @findOrCreateBy: (attributes, callback) ->
    criteria = @.where(attributes).limit(1)
    @.connection.emit 'select', criteria, (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        @.create attributes, callback

  @findOrInitializeBy: (attributes, callback) ->
    criteria = @.where(attributes).limit(1)
    @.connection.emit 'select', criteria, (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        @.init attributes, callback

  @all: (options, callback) ->
    if typeof options is 'function'
      callback = options;
      options  = {}
    criteria = new Criteria(@, options)
    @.connection.emit 'select', criteria, (err, result) =>
      instances = _(result.rows).map (attributes) =>
        new @ attributes
      callback err, instances

  @count: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    criteria = new Criteria(@, options)
                     .only("COUNT(*)")
    @.connection.emit 'select', criteria, (err, result) =>
      callback err, result.rows[0].count

  @exists: (options, callback) ->
    criteria = new Criteria(@, options)
                     .only('id')
                     .limit(1)
    @.connection.emit 'select', criteria, (err, result) =>
      callback err, result.rowCount > 0

  @first: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    criteria = new Criteria(@, options)
                     .limit(1)
                     .ascending('id')
    @.connection.emit 'select', criteria, (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        callback err, null

  @last: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    criteria = new Criteria(@, options)
                 .limit(1)
                 .descending('id')

    @.connection.emit 'select', criteria, (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        callback err, null

module.exports = Findable
