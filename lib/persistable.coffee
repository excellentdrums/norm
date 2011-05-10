Criteria = require './criteria'

module.exports = class Persistable
  @create: (attributes, callback) ->
    attributes = [attributes] unless attributes instanceof Array
    instances = _(attributes).map (attribute) =>
      new @ attribute

    criteria = new Criteria @, {}, instances

    criteria.emit 'insert', (err, result) =>
      if result.rowCount > 1
        for index in [0..instances.length - 1]
          do (index) =>
            instances[index].set({id: result.rows[index].id})
        callback err, instances
      else
        instances[0].set({id: result.rows[0].id})
        callback err, instances[0]

  @deleteAll: (options, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    criteria = new Criteria @, options
    criteria.emit 'delete', (err, result) =>
      callback err, result.rowCount

  save: (callback) ->
    criteria = new Criteria @.constructor, {}, @
    criteria.emit 'insert', (err, result) =>
      @.set result.rows[0]
      callback err, @

  updateAttributes: (attributes, callback) ->
    @.set attributes
    criteria = new Criteria(@.constructor)
                     .set(attributes)
                     .where( { id: @.get('id') } )
    criteria.emit 'update', (err, result) =>
      callback err, @

  delete: (callback) ->
    criteria = new Criteria(@.constructor).where( { id: @.get('id') } )
    criteria.emit 'delete', (err, result) =>
      callback err, result.rowCount

  destroy: (callback) ->
    @.delete callback
