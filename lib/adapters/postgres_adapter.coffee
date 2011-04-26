class Statement
  constructor: (@parts...) ->

  toString: ->
    _(@parts).compact().join(' ') + ';'

class PostgresAdapter
  insert: (instance) ->
    new Statement(
      this._insertInto instance.tableName
      this._fields     instance.attributes
      this._values     instance.attributes
      this._returning  '*'
    ).toString()

  select: (tableName, options) ->
    new Statement(
      this._select options.select
      this._from   tableName
      this._where  options.where
      this._order  options.order
      this._limit  options.limit
      this._offset options.offset
    ).toString()

  update: (tableName, options) ->
    new Statement(
      this._update    tableName
      this._set       options.set
      this._where     options.where
      this._returning '*'
    ).toString()

  delete: (tableName, options) ->
    new Statement(
      this._deleteFrom tableName
      this._where      options.where
    ).toString()

  _select: (fields) ->
    fields or= '*'
    'SELECT ' + fields

  _from: (tableName) ->
    'FROM ' + tableName

  _order: (order) ->
    directions =
      $asc:  'ASC'
      $desc: 'DESC'

    if order
      'ORDER BY ' +
      if typeof order is 'object'
        for direction, fields of order
          fields = if _(fields).isArray() then fields else [fields]
          _(fields).chain()
            .map (field) ->
              field + " " + directions[direction]
            .join(',')
            .value()
      else
        order

  _limit: (limit) ->
    'LIMIT ' + limit if limit

  _offset: (offset) ->
    'OFFSET ' + offset if offset

  _insertInto: (tableName) ->
    'INSERT INTO ' + tableName

  _fields: (attributes) ->
      '(' + _.keys(attributes).join(',') + ')'

  _values: (attributes) ->
    values = _(attributes).chain()
      .keys()
      .map((key) ->
        "'" + attributes[key] + "'")
      .join(',')
      .value()

    'VALUES (' + values + ')'

  _returning: (returning) ->
    'RETURNING ' + returning if returning

  _deleteFrom: (tableName) ->
    'DELETE FROM ' + tableName

  _where: (criteria) ->
    operators =
      $gt:   ' > '
      $gte:  ' >= '
      $lt:   ' < '
      $lte:  ' <= '
      $like: ' LIKE '

    if criteria
      conditions = _(criteria).chain()
        .keys()
        .map (key) ->
          if typeof criteria[key] is 'object'
            _(criteria[key]).chain()
              .keys()
              .map (operator) ->
                key + operators[operator] + "'" + criteria[key][operator] + "'"
              .join(' AND ')
              .value()
          else
            key + '=' + "'" + criteria[key] + "'"
        .join(' AND ')
        .value()
      'WHERE ' + conditions

  _update: (tableName) ->
    'UPDATE ' + tableName

  _set: (attributes) ->
    if attributes
      setters = _(attributes).chain()
        .keys()
        .map (key) ->
          key + "=" + "'" + attributes[key] + "'"
        .join(',')
        .value()
      "SET " + setters

module.exports = PostgresAdapter
