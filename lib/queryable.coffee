Criteria = require './criteria'

module.exports = class Queryable
  @where: (where) ->
    new Criteria { where: where }

  @limit: (limit) ->
    new Criteria { limit: limit }

  @ascending: (field) ->
    new Criteria { sort: [[field, 'asc']] }

  @asc: (field) ->
    @ascending field

  @descending: (field) ->
    new Criteria { sort: [[field, 'desc']] }

  @desc: (field) ->
    @descending field

  @skip: (skip) ->
    new Criteria { skip: skip }

  @only: (field) ->
    new Criteria { only: [field] }

  @excludes: (excludes) ->
    new Criteria { excludes: excludes }

  @orderBy: (pairs) ->
    new Criteria { sort: pairs }

  @notIn: (notIn) ->
    new Criteria { notIn: notIn }
