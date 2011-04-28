class Statement
  constructor: (@parts...) ->

  toString: ->
    _(@parts).compact().join(' ') + ';'

class PostgresAdapter
  insert: (tableName, instances) ->
    instances = [instances] unless instances instanceof Array

    fields = _(instances).chain()
      .map (instance) ->
        _(instance.attributes).keys()
      .flatten()
      .unique()
      .value()

    values = _(instances).chain()
      .map (instance) ->
        _(fields)
          .map (field) ->
            instance.attributes[field]
      .value()

    new Statement(
      @._insertInto tableName
      @._fields     fields
      @._values     values
      @._returning  '*'
    ).toString()

  select: (tableName, criteria) ->
    new Statement(
      @._select criteria.options.only
      @._from   tableName
      @._where  criteria.options.where
      @._order  criteria.options.sort
      @._limit  criteria.options.limit
      @._offset criteria.options.skip
    ).toString()

  update: (tableName, options) ->
    new Statement(
      @._update    tableName
      @._set       options.set
      @._where     options.where
      @._returning '*'
    ).toString()

  delete: (tableName, options) ->
    new Statement(
      @._deleteFrom tableName
      @._where      options.where
    ).toString()

  _select: (fields) ->
    fields or= '*'
    'SELECT ' + fields

  _from: (tableName) ->
    'FROM ' + tableName

  _order: (sort) ->
    direction =
      asc:  'ASC'
      desc: 'DESC'

    if sort
      'ORDER BY ' +
      _(sort).map (s) ->
        s[0] + ' ' + direction[s[1]]

  _limit: (limit) ->
    'LIMIT ' + limit if limit

  _offset: (offset) ->
    'OFFSET ' + offset if offset

  _insertInto: (tableName) ->
    'INSERT INTO ' + tableName

  _fields: (fields) ->
    '(' + fields + ')'

  _values: (values) ->
    rows = _(values).map (row) ->
      quoted = _(row).map (value) ->
        if value then "'" + value + "'" else 'NULL'
      '(' + quoted + ')'

    'VALUES ' + rows

  _returning: (returning) ->
    'RETURNING ' + returning if returning

  _deleteFrom: (tableName) ->
    'DELETE FROM ' + tableName

  _where: (criteria) ->
    operators =
      $eq:    ' = '
      $neq:   ' <> '
      $gt:    ' > '
      $gte:   ' >= '
      $lt:    ' < '
      $lte:   ' <= '
      $like:  ' LIKE '
      $ilike: ' ILIKE '
      $is:    ' IS '
      $isnt:  ' IS NOT '
      $in:    ' IN '
      $nin:   ' NOT IN '

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
