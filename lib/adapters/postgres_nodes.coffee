module.exports = class PostgresNodes
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

  fields: (fields) ->
    '(' + fields + ')'

  values: (values) ->
    rows = _(values).map (row) ->
      quoted = _(row).map (value) ->
        if value then "'" + value + "'" else 'NULL'
      '(' + quoted + ')'

    'VALUES ' + rows

  returning: (returning) ->
    'RETURNING ' + returning if returning

  deleteFrom: (tableName) ->
    'DELETE FROM ' + tableName

  where: (criteria) ->
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

  update: (tableName) ->
    'UPDATE ' + tableName

  set: (attributes) ->
    if attributes
      setters = _(attributes).chain()
        .keys()
        .map (key) ->
          key + "=" + "'" + attributes[key] + "'"
        .join(',')
        .value()
      "SET " + setters
