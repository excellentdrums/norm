Criteria = require './criteria'

module.exports = class Findable
  @find: (id, callback) ->
    criteria = @.where({id: id}).limit(1)
    criteria.emit 'select', (err, result) =>
      if result.rowCount > 0
        callback err, new @ result.rows[0]
      else
        callback err, null

  @findOrCreateBy: (attributes, callback) ->
    criteria = @.where(attributes).limit(1)
    criteria.emit 'select', (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        @.create attributes, callback

  @findOrInitializeBy: (attributes, callback) ->
    criteria = @.where(attributes).limit(1)
    criteria.emit 'select', (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        @.init attributes, callback

  @all: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    criteria = new Criteria(@, options)
    criteria.emit 'select', (err, result) =>
      instances = _(result.rows).map (attributes) =>
        new @ attributes
      callback err, instances

  @count: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    criteria = new Criteria(@, options)
                     .only("COUNT(*) as count")
    criteria.emit 'select', (err, result) =>
      callback err, result.rows[0].count

  @exists: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    criteria = new Criteria(@, options)
                     .only('id')
                     .limit(1)
    criteria.emit 'select', (err, result) =>
      callback err, result.rowCount > 0

  @first: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    criteria = new Criteria(@, options)
                     .limit(1)
                     .ascending('id')
    criteria.emit 'select', (err, result) =>
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
    criteria.emit 'select', (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        callback err, null
