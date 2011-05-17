MySQL         = require 'mysql'
Nodes         = require './nodes'
EventEmitter  = require('events').EventEmitter

class Statement
  constructor: (@parts...) ->

  toString: ->
    _(@parts).compact().join(' ') + ';'

module.exports = class MySQLAdapter extends EventEmitter
  constructor: (params) ->
    @nodes  = new Nodes
    @client = new MySQL.Client(params)

    @on 'insert', (criteria, callback) =>
      @client.query @insert(criteria), (err, result) =>
        resultAdapter = {}
        resultAdapter.rowCount = result.affectedRows
        resultAdapter.rows = []
        for i in [0..(result.affectedRows - 1)]
          do (i) ->
            resultAdapter.rows.push { id: (result.insertId + i) }
        callback(err, resultAdapter)

    @on 'select', (criteria, callback) =>
      @client.query @select(criteria), (err, result) =>
        resultAdapter = {}
        resultAdapter.rows = result
        resultAdapter.rowCount = result.length
        callback(err, resultAdapter)

    @on 'update', (criteria, callback) =>
      @client.query @update(criteria), (err, result) =>
        callback(err, result)

    @on 'delete', (criteria, callback) =>
      @client.query @delete(criteria), (err, result) =>
        resultAdapter = {}
        resultAdapter.rowCount = result.affectedRows
        callback(err, resultAdapter)

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
    ).toString()

  delete: (criteria) ->
    new Statement(
      @nodes.deleteFrom criteria.tableName
      @nodes.where      criteria.options.where
    ).toString()
