assert = require 'assert'
parser = require '../src/parser.coffee'

describe 'parser', ->
  it 'should parse a correct message', ->
    parsed = parser.parse '{"text": "hai", "author": "someone"}'
    assert.equal parsed.text, 'hai'
    assert.equal parsed.author, 'someone'

  it 'should fill in an author', ->
    parsed = parser.parse 'I am a non-json message'
    assert.equal parsed.author, 'unknown'

  it 'should place a non-json message in the text prop', ->
    parsed = parser.parse 'I am a non-json message'
    assert.equal parsed.text, 'I am a non-json message'
