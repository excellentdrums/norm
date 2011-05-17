module.exports = class Nodes
  select: (fields) ->
    fields or= '*'
    'SELECT ' + fields

  from: (tableName) ->
    'FROM ' + tableName

  order: (sort) ->
    direction =
      asc:  'ASC'
      desc: 'DESC'

    if sort
      'ORDER BY ' +
      _(sort).map (s) ->
        s[0] + ' ' + direction[s[1]]

  limit: (limit) ->
    'LIMIT ' + limit if limit

  offset: (offset) ->
    'OFFSET ' + offset if offset

  insertInto: (tableName) ->
    'INSERT INTO ' + tableName

  fields: (fields...) ->
    '(' + fields + ')'

  values: (values) ->
    rows = _(values).map (row) ->
      quoted = _(row).map (value) ->
        if value then "'" + value + "'" else 'NULL'
      '(' + quoted + ')'

    'VALUES ' + rows

  returning: (returning...) ->
    'RETURNING ' + returning if returning.length > 0

  deleteFrom: (tableName) ->
    'DELETE FROM ' + tableName

  where: (conditions) ->
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

    if conditions
      _conditions = _(conditions).chain()
        .keys()
        .map (key) ->
          if typeof conditions[key] is 'object'
            _(conditions[key]).chain()
              .keys()
              .map (operator) ->
                _values = conditions[key][operator]
                _values = if _values instanceof Array
                  v = _(_values).map (_value) ->
                    "'" + _value + "'"
                  '(' + v + ')'
                else
                  if _values then "'" + _values + "'" else 'NULL'
                key + operators[operator] + _values
              .join(' AND ')
              .value()
          else
            key + '=' + "'" + conditions[key] + "'"
        .join(' AND ')
        .value()
      'WHERE ' + _conditions

  update: (tableName) ->
    'UPDATE ' + tableName

  set: (attributes) ->
    if attributes
      setters = _(attributes).chain()
        .keys()
        .map (key) ->
          value = if attributes[key] then "'" + attributes[key] + "'" else 'NULL'
          key + "=" + value
        .value()
      "SET " + setters
