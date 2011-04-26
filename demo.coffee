Norm = require './lib'

connectionParams =
  adapter:  'PostgresAdapter'
  user:     'jimmy'
  password: ''
  database: 'hooray'
  host:     'localhost'
  port:     5432

Norm.connect(connectionParams);

class Person extends Norm.Model
  @tableName: 'people'
  fullName: ->
    this.get('first_name')  + ' ' +
    this.get('middle_name') + ' ' +
    this.get('last_name')
  speak: ->
    console.log 'Blah, blah, blah...'

say = (err, result, message) ->
  console.log '=============> ' + message
  console.log 'ERROR: '   + util.inspect(err)
  console.log 'OBJECT:\n' + util.inspect(result)

declan =
  first_name:  "Declan"
  middle_name: "Thomas"
  last_name:   "Drannbauer"
  age:         1

dylan =
  first_name:  "Dylan"
  middle_name: "James"
  last_name:   "Drannbauer"
  age:         4

kyra =
  first_name:  "Kyra"
  middle_name: "Grace"
  last_name:   "Drannbauer"
  age:         8

jim =
  first_name:  'James'
  middle_name: 'William'
  last_name:   'Drannbauer'
  age:         39

ducklanOptions =
  where:
    first_name:  "Ducklan"
    middle_name: "Thomas"
    last_name:   "Drannbauer"

dylanOptions =
  where:
    first_name:  "Dylan"
    middle_name: "James"
    last_name:   "Drannbauer"

kyraOptions =
  where:
    first_name:  "Kyra"
    middle_name: "Grace"
    last_name:   "Drannbauer"

jimOptions =
  where:
    first_name:  "James"
    middle_name: "William"
    last_name:   "Drannbauer"

# person = new Person(jim)
# person.speak()
#
# console.log 'full name: '          + person.fullName()
# console.log 'default table name: ' + Norm.Model.tableName
# console.log 'Person table name: '  + Person.tableName
#
Person.deleteAll (err, result) ->
  say err, result, 'Deleted all people'
  createDeclan(err, result)

createDeclan = (err, result) ->
  Person.create declan, (err, person) ->
    say err, person, 'Created Declan'
    findDeclan(err, person)

findDeclan = (err, person) ->
  Person.find person.get('id'), (err, person) ->
    say err, person, 'Found Declan'
    updateDeclan(err, person)

updateDeclan = (err, person) ->
  person.updateAttributes { first_name: 'Ducklan' } , (err, person) ->
    say err, person, 'Changed Declan to Ducklan'
    findDucklan(err,person)

findDucklan = (err, person) ->
  Person.find person.get('id'), (err, person) ->
    say err, person, 'Found Ducklan'
    initDylan(err, person)

initDylan = (err, person) ->
  Person.init dylan, (err, person) ->
    say err, person, 'Initialized Dylan'
    saveDylan(err, person)

saveDylan = (err, person) ->
  person.save (err, person) ->
    say err, person, 'Saved Dylan'
    allPeople(err, person)

allPeople = (err, person) ->
  Person.all (err, people) ->
    say err, people, 'Found all people'
    allDylans(err, people)

allDylans = (err, people) ->
  Person.all dylanOptions, (err, dylans) ->
    say err, dylans, 'Found all Dylans'
    allJims(err, dylans)

allJims = (err, dylans) ->
  Person.all jimOptions, (err, jims) ->
    say err, jims, 'Found all Jims, none'
    countPeople(err, jims)

countPeople = (err, jims) ->
  Person.count (err, count) ->
    say err, count, 'Count of all people'
    countDucklans(err, count)

countDucklans = (err, count) ->
  Person.count ducklanOptions, (err, count) ->
    say err, count, 'Count of all Ducklans'
    dylanExists(err, count)

dylanExists = (err, count) ->
  Person.exists dylanOptions, (err, result) ->
    say err, result, 'Dylan exists'
    kyraDoesntExist(err, result)

kyraDoesntExist = (err, result) ->
  Person.exists kyraOptions, (err, result) ->
    say err, result, 'Kyra does not exist...'
    findOrCreateKyra(err, result)

findOrCreateKyra = (err, result) ->
  Person.findOrCreateBy kyra, (err, person) ->
    say err, person, '...but now she does!'
    findOrCreateDylan(err, person)

findOrCreateDylan = (err, person) ->
  Person.findOrCreateBy dylan, (err, person) ->
    say err, person, 'Dylan already existed and so was found'
    findOrInitializeJim(err, person)

findOrInitializeJim = (err, person) ->
  Person.findOrInitializeBy jim, (err, person) ->
    say err, person, 'Jim has been initialized'
    findOrInitializeKyra(err, person)

findOrInitializeKyra = (err, person) ->
  Person.findOrInitializeBy kyra, (err, person) ->
    say err, person, 'Kyra has been found'
    firstPerson(err, person)

firstPerson = (err, person) ->
  Person.first (err, person) ->
    say err, person, 'Found the first person'
    firstDylan(err, person)

firstDylan = (err, person) ->
  Person.first dylanOptions, (err, person) ->
    say err, person, 'Found the first Dylan'
    lastPerson(err, person)

lastPerson = (err, person) ->
  Person.last (err, person) ->
    say err, person, 'Found the last person'
    lastDylan(err, person)

lastDylan = (err, person) ->
  Person.last dylanOptions, (err, person) ->
    say err, person, 'Found the last Dylan'
    allPeopleOlderThan3(err, person)

allPeopleOlderThan3 = (err, people) ->
  olderOptions =
    where:
      age:
        $lt: 5
  Person.all olderOptions, (err, elders) ->
    say err, elders, 'Found all People older than 3'

Norm.Model.connection.disconnect()
