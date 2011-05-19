Norm = require('../lib')

class Thing extends Norm.Mixable
  @mixin Norm.Fields

describe 'Norm.Fields', ->
  beforeEach ->
    @.addMatchers
      toBeInstanceOf: (expected) ->
        @.actual instanceof expected

  afterEach ->
    delete Thing.fields

  it 'has no fields until one is defined', ->
    expect(Thing.fields).toBeUndefined()

  it 'adds a field with a null default to the fields collection', ->
    Thing.field 'whatever'
    expect(Thing.fields).toEqual( { whatever: { default: null } } )

  it 'adds a field with an actual default to the fields collection', ->
    Thing.field 'whatever', { default: 'hooray!' }
    expect(Thing.fields).toEqual( { whatever: { default: 'hooray!' } } )

  it 'has default attributes', ->
    Thing.field 'first', { default: 'jim' }
    Thing.field 'last',  { default: 'drannbauer' }
    expect(Thing.defaultAttributes()).toEqual( { first: 'jim', last: 'drannbauer' } )

  it 'get a default attribute by name', ->
    Thing.field 'first', { default: 'jim' }
    Thing.field 'last',  { default: 'drannbauer' }
    expect(Thing.defaultAttribute('first')).toEqual('jim')
    expect(Thing.defaultAttribute('last')).toEqual('drannbauer')
