Norm = require '../lib'

vows   = require 'vows'
assert = require 'assert'
eyes   = require 'eyes'

class Person extends Norm.Model
  @tableName: 'people'

suite = vows.describe 'Norm.Model'

suite.addBatch
  'Model.tableName':
    topic: -> Person
    'is the class name lowercase pluralized': (klass) ->
      assert.equal klass.tableName, 'people'

  'Model#tableName':
    topic: -> new Person()
    'is the class name lowercase pluralized': (model) ->
      assert.equal model.tableName, 'people'

.export(module)