Mixable     = require './mixable'
Queryable   = require './queryable'
Persistable = require './persistable'
Findable    = require './findable'

module.exports = class Model extends Mixable
  @extend Queryable
  @extend Persistable
  @extend Findable

  constructor: (@attributes) ->
    @.tableName = @.constructor.tableName

  @init: (attributes, callback) ->
    callback null, new @ attributes

  save: (callback) ->
    @.constructor.connection.emit 'insert', @.constructor, @, (err, result) =>
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
