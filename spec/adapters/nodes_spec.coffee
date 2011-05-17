Nodes = require('../../lib').Nodes

describe 'Nodes', ->
  beforeEach ->
    @.addMatchers
      toBeInstanceOf: (expected) ->
        @.actual instanceof expected

  nodes = new Nodes

  it 'is Nodes', ->
    expect(nodes).toBeInstanceOf(Nodes)

  describe '#select', ->
    it 'defaults to *', ->
      select = nodes.select()
      expect(select).toEqual('SELECT *')

    it 'selects a given field', ->
      select = nodes.select('whatever')
      expect(select).toEqual('SELECT whatever')

    it 'selects an array of given fields', ->
      select = nodes.select(['whatever', 'whatnot'])
      expect(select).toEqual('SELECT whatever,whatnot')

  describe '#from', ->
    it 'uses the given table name', ->
      from = nodes.from('whatever')
      expect(from).toEqual('FROM whatever')

  describe '#order', ->
    it 'orders by one field/direction pair', ->
      order = nodes.order([['blarg', 'asc']])
      expect(order).toEqual('ORDER BY blarg ASC')

    it 'orders by multiple field/direction pairs', ->
      order = nodes.order([['blarg', 'asc'], ['blorg', 'desc']])
      expect(order).toEqual('ORDER BY blarg ASC,blorg DESC')

  describe '#limit', ->
    it 'defaults to undefined', ->
      limit = nodes.limit()
      expect(limit).toBeUndefined()

    it 'limits the given value', ->
      limit = nodes.limit(5)
      expect(limit).toEqual("LIMIT 5")

  describe '#offset', ->
    it 'defaults to undefined', ->
      offset = nodes.offset()
      expect(offset).toBeUndefined()

    it 'offsets the given value', ->
      offset = nodes.offset(5)
      expect(offset).toEqual("OFFSET 5")

  describe '#insertInto', ->
    it 'inserts into the given table', ->
      into = nodes.insertInto('whatever')
      expect(into).toEqual('INSERT INTO whatever')

  describe '#fields', ->
    it 'is a parenthesized single field', ->
      fields = nodes.fields('blarg')
      expect(fields).toEqual('(blarg)')

    it 'is a parenthesized csv of fields from a splat', ->
      fields = nodes.fields('blarg', 'blorg')
      expect(fields).toEqual('(blarg,blorg)')

    it 'is a parenthesized csv of fields from an array', ->
      fields = nodes.fields(['blarg', 'blorg'])
      expect(fields).toEqual('(blarg,blorg)')

  describe '#values', ->
    it 'is a single row of parenthesized and quoted values', ->
      values = nodes.values([['blarg', 'blorg']])
      expect(values).toEqual("VALUES ('blarg','blorg')")

    it 'is multiple rows of parenthesized and quoted values', ->
      values = nodes.values([['blarg', 'blorg'], ['blurg', 'blah']])
      expect(values).toEqual("VALUES ('blarg','blorg'),('blurg','blah')")

    it 'is multiple rows of parenthesized and quoted values with NULLs', ->
      values = nodes.values([['blarg', null], [null, 'blah']])
      expect(values).toEqual("VALUES ('blarg',NULL),(NULL,'blah')")

  describe '#returning', ->
    it 'defaults to undefined', ->
      returning = nodes.returning()
      expect(returning).toBeUndefined()

    it 'returning a single given field', ->
      returning = nodes.returning('id')
      expect(returning).toEqual("RETURNING id")

    it 'returning multiple given fields from splat', ->
      returning = nodes.returning('id', 'name')
      expect(returning).toEqual("RETURNING id,name")

    it 'returning multiple given fields from array', ->
      returning = nodes.returning(['id', 'name'])
      expect(returning).toEqual("RETURNING id,name")

  describe '#deleteFrom', ->
    it 'deletes from the given table', ->
      deleteFrom = nodes.deleteFrom('everything')
      expect(deleteFrom).toEqual('DELETE FROM everything')

  describe '#where', ->
    describe 'no operator', ->
      it 'defaults to = with one condition', ->
        where = nodes.where( { jim: 'awesome' } )
        expect(where).toEqual("WHERE jim='awesome'")

      it 'defaults to = with two conditions', ->
        where = nodes.where( { name: 'jim', description: 'awesome' } )
        expect(where).toEqual("WHERE name='jim' AND description='awesome'")

    describe '$eq', ->
      it 'uses = with one condition', ->
        where = nodes.where( { jim: { $eq: 'awesome' } } )
        expect(where).toEqual("WHERE jim = 'awesome'")

      it 'uses = with two conditions', ->
        where = nodes.where( { name: { $eq: 'jim' }, description: { $eq: 'awesome' } } )
        expect(where).toEqual("WHERE name = 'jim' AND description = 'awesome'")

    describe '$neq', ->
      it 'uses <> with one condition', ->
        where = nodes.where( { jim: { $neq: 'awesome' } } )
        expect(where).toEqual("WHERE jim <> 'awesome'")

      it 'uses <> with two conditions', ->
        where = nodes.where( { name: { $neq: 'jim' }, description: { $neq: 'awesome' } } )
        expect(where).toEqual("WHERE name <> 'jim' AND description <> 'awesome'")

    describe '$gt', ->
      it 'uses > with one condition', ->
        where = nodes.where( { jim: { $gt: 'awesome' } } )
        expect(where).toEqual("WHERE jim > 'awesome'")

      it 'uses > with two conditions', ->
        where = nodes.where( { name: { $gt: 'jim' }, description: { $gt: 'awesome' } } )
        expect(where).toEqual("WHERE name > 'jim' AND description > 'awesome'")

    describe '$gte', ->
      it 'uses >= with one condition', ->
        where = nodes.where( { jim: { $gte: 'awesome' } } )
        expect(where).toEqual("WHERE jim >= 'awesome'")

      it 'uses >= with two conditions', ->
        where = nodes.where( { name: { $gte: 'jim' }, description: { $gte: 'awesome' } } )
        expect(where).toEqual("WHERE name >= 'jim' AND description >= 'awesome'")

    describe '$lt', ->
      it 'uses < with one condition', ->
        where = nodes.where( { jim: { $lt: 'awesome' } } )
        expect(where).toEqual("WHERE jim < 'awesome'")

      it 'uses < with two conditions', ->
        where = nodes.where( { name: { $lt: 'jim' }, description: { $lt: 'awesome' } } )
        expect(where).toEqual("WHERE name < 'jim' AND description < 'awesome'")

    describe '$lte', ->
      it 'uses <= with one condition', ->
        where = nodes.where( { jim: { $lte: 'awesome' } } )
        expect(where).toEqual("WHERE jim <= 'awesome'")

      it 'uses <= with two conditions', ->
        where = nodes.where( { name: { $lte: 'jim' }, description: { $lte: 'awesome' } } )
        expect(where).toEqual("WHERE name <= 'jim' AND description <= 'awesome'")

    describe '$like', ->
      it 'uses LIKE with one condition', ->
        where = nodes.where( { jim: { $like: '%awesome%' } } )
        expect(where).toEqual("WHERE jim LIKE '%awesome%'")

      it 'uses LIKE with two conditions', ->
        where = nodes.where( { name: { $like: '%jim' }, description: { $like: '%awesome' } } )
        expect(where).toEqual("WHERE name LIKE '%jim' AND description LIKE '%awesome'")

    describe '$ilike', ->
      it 'uses ILIKE with one condition', ->
        where = nodes.where( { jim: { $ilike: '%awesome%' } } )
        expect(where).toEqual("WHERE jim ILIKE '%awesome%'")

      it 'uses ILIKE with two conditions', ->
        where = nodes.where( { name: { $ilike: '%jim' }, description: { $ilike: '%awesome' } } )
        expect(where).toEqual("WHERE name ILIKE '%jim' AND description ILIKE '%awesome'")

    describe '$is', ->
      it 'uses IS with one condition', ->
        where = nodes.where( { jim: { $is: null } } )
        expect(where).toEqual("WHERE jim IS NULL")

      it 'uses IS with two conditions', ->
        where = nodes.where( { name: { $is: null }, description: { $is: null } } )
        expect(where).toEqual("WHERE name IS NULL AND description IS NULL")

    describe '$isnt', ->
      it 'uses IS NOT with one condition', ->
        where = nodes.where( { jim: { $isnt: null } } )
        expect(where).toEqual("WHERE jim IS NOT NULL")

      it 'uses IS NOT with two conditions', ->
        where = nodes.where( { name: { $isnt: null }, description: { $isnt: null } } )
        expect(where).toEqual("WHERE name IS NOT NULL AND description IS NOT NULL")

    describe '$in', ->
      it 'uses IN with parenthesized values', ->
        where = nodes.where( { name: { $in: ['jim', 'kerry'] } } )
        expect(where).toEqual("WHERE name IN ('jim','kerry')")

      it 'uses NOT IN with parenthesized values', ->
        where = nodes.where( { name: { $nin: ['jim', 'kerry'] } } )
        expect(where).toEqual("WHERE name NOT IN ('jim','kerry')")

  describe '#update', ->
    it 'updates the given table', ->
      into = nodes.update('whatever')
      expect(into).toEqual('UPDATE whatever')

  describe '#set', ->
    it 'sets the given value', ->
      set = nodes.set( { jim: 'awesome' } )
      expect(set).toEqual("SET jim='awesome'")

    it 'sets multiple given values', ->
      set = nodes.set( { name: 'jim', description: 'awesome' } )
      expect(set).toEqual("SET name='jim',description='awesome'")

    it 'sets the given null value', ->
      set = nodes.set( { jim: null } )
      expect(set).toEqual("SET jim=NULL")
