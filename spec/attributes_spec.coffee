Norm = require('../lib')

class Thing extends Norm.Mixable
  @mixin Norm.Attributes
  constructor: (@attributes = {}, @previousAttributes = {}) ->

describe 'Attributes', ->
  it 'sets attributes', ->
    thing = new Thing
    thing.set( { something: 'awesome' } )
    expect(thing.attributes).toEqual( { something: 'awesome'} )

  it 'gets attributes', ->
    thing = new Thing { something: 'awesome' }
    expect(thing.get('something')).toEqual('awesome')

  it 'is new when there is no id', ->
    thing = new Thing
    expect(thing.isNew()).toBeTruthy()

  it 'is not new when there is an id', ->
    thing = new Thing( { id: 12345 } )
    expect(thing.isNew()).toBeFalsy()

  describe '#hasChanged', ->
    it 'is false by default', ->
      thing = new Thing
      expect(thing.hasChanged()).toBeFalsy()

    it 'is true when an attribute has been set', ->
      thing = new Thing
      thing.set( { something: 'cool' } )
      expect(thing.hasChanged()).toBeTruthy()

    describe 'when testing a specific attribute', ->
      it 'is false when the attribute has not been set', ->
        thing = new Thing
        expect(thing.hasChanged('something')).toBeFalsy()

      it 'is false when the attribute has been set but not changed', ->
        thing = new Thing( {}, { something: 'cool' } )
        thing.set( { something: 'cool' } )
        expect(thing.hasChanged('something')).toBeFalsy()

      it 'is false when the attribute has not been set even if others have', ->
        thing = new Thing
        thing.set( { something: 'cool' } )
        expect(thing.hasChanged('other')).toBeFalsy()

      it 'is true when the attribute has been set even if others have not', ->
        thing = new Thing
        thing.set( { something: 'cool' } )
        expect(thing.hasChanged('something')).toBeTruthy()

  it 'tracks changed attributes', ->
    now =
      first: 'jim'
      last:  'drannbauer'
    previous =
      first: 'james'
      last:  'drannbauer'
    thing = new Thing(now, previous)
    thing.set( { middle: 'william' } )
    expect(thing.changedAttributes()).toEqual( { first: 'jim', middle: 'william' } )
