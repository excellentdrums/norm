module.exports = class Persistable
  @create: (attributes, callback) ->
    attributes = [attributes] unless attributes instanceof Array
    instances = _(attributes).map (attribute) =>
      new @ attribute

    @.connection.emit 'insert', this, instances, (err, result) =>
      if result.rowCount > 1
        instances = _(result.rows).map (attributes) =>
          new @ attributes
        callback err, instances
      else
        instance = new @ result.rows[0]
        callback err, instance

  @deleteAll: (options, callback) ->
    if typeof options is 'function'
      callback = options;
      options  = {}
    @.connection.emit 'delete', @, options, (err, result) =>
      callback err, result.rowCount
