EventEmitter = require('events').EventEmitter

module.exports = class Criteria extends EventEmitter
  constructor: (@klass = {}, @options = {}, @instances) ->
    @tableName = @klass.tableName

    @on 'insert', (callback) =>
      @klass.connection.adapter.emit 'insert', @, callback

    @on 'select', (callback) =>
      @klass.connection.adapter.emit 'select', @, callback

    @on 'update', (callback) =>
      @klass.connection.adapter.emit 'update', @, callback

    @on 'delete', (callback) =>
      @klass.connection.adapter.emit 'delete', @, callback

  where: (where) ->
    @options.where or= {}
    _(@options.where).extend where
    @

  and: (where) ->
    @where where

  limit: (limit) ->
    @options.limit = limit
    @

  ascending: (field) ->
    @options.sort or= []
    @options.sort.push [field, 'asc']
    @

  asc: (field) ->
    @ascending field

  descending: (field) ->
    @options.sort or= []
    @options.sort.push [field, 'desc']
    @

  desc: (field) ->
    @descending field

  skip: (skip) ->
    @options.skip = skip
    @

  only: (field) ->
    @options.only or= []
    @options.only.push field
    @

  excludes: (excludes) ->
    @options.excludes or= {}
    _(@options.excludes).extend excludes
    @

  orderBy: (pairs) ->
    @options.sort or= []
    @options.sort.push pairs...
    @

  notIn: (notIn) ->
    @options.notIn or= {}
    for key, val of notIn
      @options.notIn[key] or= []
      @options.notIn[key].push val...
    @

  set: (set) ->
    @options.set or= {}
    _(@options.set).extend set
    @
