Criteria      = require './criteria'
Mixable       = require './mixable'
Queryable     = require './queryable'
Persistable   = require './persistable'
Findable      = require './findable'
Connectable   = require './connectable'
Fields        = require './fields'
Attributes    = require './attributes'

module.exports = class Model extends Mixable
  @mixin Queryable
  @mixin Persistable
  @mixin Findable
  @mixin Connectable
  @mixin Fields
  @mixin Attributes

  constructor: (attributes) ->
    @tableName = @.constructor.tableName
    @attributes = {}
    if @.constructor.defaultAttributes()
      @.set @.constructor.defaultAttributes()
    @.set attributes

  @init: (attributes, callback) ->
    callback null, new @ attributes
