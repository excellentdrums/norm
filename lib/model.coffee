Criteria      = require './criteria'
Mixable       = require './mixable'
Queryable     = require './queryable'
Persistable   = require './persistable'
Findable      = require './findable'
Connectable   = require './connectable'
Fields        = require './fields'
Attributes    = require './attributes'

module.exports = class Model extends Mixable
  @extend  Queryable
  @include Persistable
  @extend  Findable
  @extend  Connectable
  @extend  Fields
  @include Attributes

  constructor: (attributes) ->
    @tableName = @.constructor.tableName
    @.attributes = {}
    if @.constructor.defaults
      @.set @.constructor.defaults
    @.set attributes

  @init: (attributes, callback) ->
    callback null, new @ attributes
