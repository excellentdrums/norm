class Model
  constructor: (@attributes) ->
    @.tableName = @.constructor.tableName

  @init: (attributes, callback) ->
    callback null, new @ attributes

  @find: (id, callback) ->
    options =
      where:
        id: id
      limit: 1
    @.connection.emit 'select', @, options, (err, result) =>
      callback err, new @ result.rows[0]

  @findOrCreateBy: (attributes, callback) ->
    options =
      where: attributes
      limit: 1
    @.connection.emit 'select', this, options, (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        @.create attributes, callback

  @findOrInitializeBy: (attributes, callback) ->
    options =
      where: attributes
      limit: 1
    @.connection.emit 'select', this, options, (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        @.init attributes, callback

  @create: (attributes, callback) ->
    instance = new @(attributes)
    instance.save callback

  @deleteAll: (options, callback) ->
    if typeof options is 'function'
      callback = options;
      options  = {}
    @.connection.emit 'delete', @, options, (err, result) =>
      callback err, result.rowCount

  @all: (options, callback) ->
    if typeof options is 'function'
      callback = options;
      options  = {}
    @.connection.emit 'select', @, options, (err, result) =>
      instances = _(result.rows).map (attributes) =>
        new @ attributes
      callback err, instances

  @count: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    options = _({ select: "COUNT(*)" }).extend options
    @.connection.emit 'select', @, options, (err, result) =>
      callback err, result.rows[0].count

  @exists: (options, callback) ->
    options = _({ select: 'id', limit: 1 }).extend options
    @.connection.emit 'select', this, options, (err, result) =>
      callback err, result.rowCount > 0

  @first: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    options = _({ limit: 1 }).extend options
    @.connection.emit 'select', this, options, (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        callback err, null

  @last: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    options = _({ limit: 1, order: { $desc: 'id' } }).extend options
    @.connection.emit 'select', this, options, (err, result) =>
      if result.rowCount > 0
        @.init result.rows[0], callback
      else
        callback err, null

  @paginate: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    options = _({ limit: 10, order: 'id ASC', offset: 0 }).extend options
    @.all options, callback

  save: (callback) ->
    @.constructor.connection.emit 'insert', @, (err, result) =>
      @.set result.rows[0]
      callback err, @

  updateAttributes: (attributes, callback) ->
    options =
      where:
        id: @.get('id')
      set: attributes
    @.constructor.connection.emit 'update', @, options, (err, result) =>
      @.set result.rows[0]
      callback err, @

  delete: (callback) ->
    options =
      where:
        id: @.get('id')
    @.constructor.connection.emit 'delete', @, options, (err, result) =>
      console.log err
      callback err, result.rowCount

  destroy: (callback) ->
    @.delete callback

  get: (attr) ->
    @.attributes[attr]

  set: (attrs) ->
    if not attrs then return @
    now = @.attributes

    for attr of attrs
      val = attrs[attr]
      if not _.isEqual(now[attr], val)
        now[attr] = val

module.exports = Model
