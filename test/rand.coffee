assert = require 'assert'
random = require '../src/rand.coffee'

describe 'rand', ->
  it 'should return a random secret of the correct length', ->
    assert.equal random.secret().length, 23

  it 'should return a name', ->
    assert random.name()
