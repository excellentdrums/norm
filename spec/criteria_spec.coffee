Criteria = require('../lib').Criteria

describe 'Criteria', ->
  beforeEach ->
    @.addMatchers
      toBeInstanceOf: (expected) ->
        @.actual instanceof expected

  criteria = new Criteria()
               .excludes( { blarg: 'blarg' } )
               .excludes( { blurg: 'blurg' } )
               .only('title')
               .only('blurb')
               .desc('middle_name')
               .descending('age')
               .asc('first_name')
               .ascending('last_name')
               .limit(1)
               .where( { this: 'that' } )
               .and( { me: 'Jim' } )
               .limit(2)
               .skip(20)
               .skip(30)
               .orderBy([['awesome', 'asc'], ['brilliant', 'desc']])
               .notIn( { blorg: ['blorg', 'blargy'] } )
               .notIn( { hooray: ['yippee'], blorg: ['WTF!??!?!'] } )

  it 'is a Criteria', ->
    expect(criteria).toBeInstanceOf(Criteria)

  it 'has where option', ->
    expect(criteria.options.where).toEqual( { this: 'that', me: 'Jim' } )

  it 'has limit option', ->
    expect(criteria.options.limit).toEqual(2)

  it 'has skip option', ->
    expect(criteria.options.skip).toEqual(30)

  it 'has only option', ->
    expect(criteria.options.only).toEqual(['title', 'blurb'])

  it 'has excludes option', ->
    expect(criteria.options.excludes).toEqual( { blarg: 'blarg', blurg: 'blurg' } )

  it 'has sort option', ->
    sort = [
      ['middle_name', 'desc']
      ['age',         'desc']
      ['first_name',  'asc']
      ['last_name',   'asc']
      ['awesome',     'asc']
      ['brilliant',   'desc']
    ]

    expect(criteria.options.sort).toEqual(sort)

  it 'has notIn option', ->
    expect(criteria.options.notIn).toEqual( { hooray: ['yippee'], blorg: ['blorg', 'blargy', 'WTF!??!?!'] } )
