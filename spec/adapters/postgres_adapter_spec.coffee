Norm = require '../../lib'

describe 'Norm.Adapters.PostgresAdapter', ->
  beforeEach ->
    @.addMatchers
      toBeInstanceOf: (expected) ->
        @.actual instanceof expected

  adapter = new Norm.Adapters.PostgresAdapter()

  it 'is an instance of PostgresAdapter', ->
    expect(adapter).toBeInstanceOf(Norm.Adapters.PostgresAdapter)

  describe '#select', ->
    it 'returns a default query', ->
      criteria = new Norm.Criteria({tableName: 'people'})
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people;")

    it 'returns a query with one select option', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .only('first_name')
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT first_name FROM people;")

    it 'returns a query with multiple select options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                   .only(['first_name', 'last_name'])
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT first_name,last_name FROM people;")

    it 'returns a query with one where option', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .where( { first_name: 'Jim' } )
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people WHERE first_name='Jim';")

    it 'returns a query with multiple where options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .where( { first_name: 'Jim' } )
                       .where( { last_name:  'Drannbauer' } )
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people WHERE first_name='Jim' AND last_name='Drannbauer';")

    it 'returns a query with one where operator option', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .where( { age: { $gt: 3 } } )
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people WHERE age > '3';")

    it 'returns a query with multiple where operator options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .where( { age: { $gt: 3 } } )
                       .where( { first_name: { $like: '%im%' } } )
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people WHERE age > '3' AND first_name LIKE '%im%';")

    it 'returns a query with order by options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .orderBy([['last_name', 'asc']])
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people ORDER BY last_name ASC;")

    it 'returns a query with order ascending options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                                 .ascending('last_name')
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people ORDER BY last_name ASC;")

    it 'returns a query with multiple ascending and descending order options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .asc('last_name')
                       .asc('first_name')
                       .desc('age')
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people ORDER BY last_name ASC,first_name ASC,age DESC;")

    it 'returns a query with limit and offset options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .limit(20)
                       .skip(40)
      actual   = adapter.select(criteria)
      expect(actual).toEqual("SELECT * FROM people LIMIT 20 OFFSET 40;")

  describe '#insert', ->
    it 'returns a query with one attribute', ->
      instances =
        attributes:
          first_name: 'Jim'
      criteria = new Norm.Criteria({tableName: 'people'}, {}, instances)
      actual   = adapter.insert(criteria)
      expect(actual).toEqual("INSERT INTO people (first_name) VALUES ('Jim') RETURNING *;")

    it 'returns a query with multiple attributes', ->
      instances =
        attributes:
          first_name: 'Jim'
          last_name:  'Drannbauer'
      criteria = new Norm.Criteria({tableName: 'people'}, {}, instances)
      actual   = adapter.insert(criteria)
      expect(actual).toEqual("INSERT INTO people (first_name,last_name) VALUES ('Jim','Drannbauer') RETURNING *;")

    it 'returns a query with multiple attributes and multiple rows', ->
      instances = [
        { attributes: { first_name: 'Jim',   last_name:  'Drannbauer' } }
        { attributes: { first_name: 'Kerry', last_name:  'Drannbauer' } }
      ]
      criteria = new Norm.Criteria({tableName: 'people'}, {}, instances)
      actual   = adapter.insert(criteria)
      expect(actual).toEqual("INSERT INTO people (first_name,last_name) VALUES ('Jim','Drannbauer'),('Kerry','Drannbauer') RETURNING *;")

    it 'returns a query with multiple mixed (NULL) attributes and multiple rows', ->
      instances = [
        { attributes: { first_name: 'James', middle_name: 'William'    } }
        { attributes: { first_name: 'Kerry', last_name:   'Drannbauer' } }
      ]
      criteria = new Norm.Criteria({ tableName: 'people' }, {}, instances)
      actual = adapter.insert(criteria)
      expect(actual).toEqual("INSERT INTO people (first_name,middle_name,last_name) VALUES ('James','William',NULL),('Kerry',NULL,'Drannbauer') RETURNING *;")

  describe '#update', ->
    it 'returns a query with one set option', ->
      criteria = new Norm.Criteria( { tableName: 'people' } )
                       .set( { first_name: 'Jim' } )
      actual   = adapter.update(criteria)
      expect(actual).toEqual("UPDATE people SET first_name='Jim' RETURNING *;")

    it 'returns a query with multiple set options', ->
      criteria = new Norm.Criteria( { tableName: 'people' } )
                       .set( { first_name: 'Jim' } )
                       .set( { last_name:  'Drannbauer' } )
      actual   = adapter.update(criteria)
      expect(actual).toEqual("UPDATE people SET first_name='Jim',last_name='Drannbauer' RETURNING *;")

    it 'returns a query with one where option', ->
      criteria = new Norm.Criteria( { tableName: 'people' } )
                       .set( { first_name: 'Jim' } )
                       .set( { last_name:  'Drannbauer' } )
                       .where( { id: 13 } )
      actual   = adapter.update(criteria)
      expect(actual).toEqual("UPDATE people SET first_name='Jim',last_name='Drannbauer' WHERE id='13' RETURNING *;")

    it 'returns a query with multiple where options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .set( { first_name: 'Jim' } )
                       .set( { last_name:  'Drannbauer' } )
                       .where( { first_name: 'Gym' } )
                       .where( { last_name:  'Jambager' } )
      actual   = adapter.update(criteria)
      expect(actual).toEqual("UPDATE people SET first_name='Jim',last_name='Drannbauer' WHERE first_name='Gym' AND last_name='Jambager' RETURNING *;")

    it 'returns a query with multiple where operation options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .set( { season: 'winter' } )
                       .where( { date: { $gt: '2010-12-21', $lt: '2011-03-21' } } )
      actual   = adapter.update(criteria)
      expect(actual).toEqual("UPDATE people SET season='winter' WHERE date > '2010-12-21' AND date < '2011-03-21' RETURNING *;")

  describe '#delete', ->
    it 'returns a default query', ->
      criteria = new Norm.Criteria({tableName: 'people'})
      actual   = adapter.delete(criteria)
      expect(actual).toEqual("DELETE FROM people;")

    it 'returns a query with one where option', ->
      criteria = new Norm.Criteria({tableName: 'people'}).where({ id: 13 })
      actual   = adapter.delete(criteria)
      expect(actual).toEqual("DELETE FROM people WHERE id='13';")

    it 'returns a query with multiple where options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .where( { first_name: 'harry'  } )
                       .where( { last_name:  'potter' } )
      actual   = adapter.delete(criteria)
      expect(actual).toEqual("DELETE FROM people WHERE first_name='harry' AND last_name='potter';")

    it 'returns a query with multiple where operation options', ->
      criteria = new Norm.Criteria({tableName: 'people'})
                       .where( { date: { $gt: '2010-12-21', $lt: '2011-03-21' } } )
      actual   = adapter.delete(criteria)
      expect(actual).toEqual("DELETE FROM people WHERE date > '2010-12-21' AND date < '2011-03-21';")
