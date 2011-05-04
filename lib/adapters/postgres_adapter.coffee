Postgres      = require 'pg'
PostgresNodes = require './postgres_nodes'
EventEmitter  = require('events').EventEmitter

class Statement
  constructor: (@parts...) ->

  toString: ->
    _(@parts).compact().join(' ') + ';'

class PostgresAdapter extends EventEmitter
  constructor: (params) ->
    @nodes  = new PostgresNodes
    @client = new Postgres.Client(params)
    @on 'query', (query, callback) =>
      @client.query query, (err, result) =>
        callback(err, result)

  insert: (criteria) ->
    instances = criteria.instances
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
      @nodes.insertInto criteria.tableName
      @nodes.fields     fields
      @nodes.values     values
      @nodes.returning  '*'
    ).toString()

  select: (criteria) ->
    new Statement(
      @nodes.select criteria.options.only
      @nodes.from   criteria.tableName
      @nodes.where  criteria.options.where
      @nodes.order  criteria.options.sort
      @nodes.limit  criteria.options.limit
      @nodes.offset criteria.options.skip
    ).toString()

  update: (criteria) ->
    new Statement(
      @nodes.update    criteria.tableName
      @nodes.set       criteria.options.set
      @nodes.where     criteria.options.where
      @nodes.returning '*'
    ).toString()

  delete: (criteria) ->
    new Statement(
      @nodes.deleteFrom criteria.tableName
      @nodes.where      criteria.options.where
    ).toString()

module.exports = PostgresAdapter
