assert = require 'assert'
codec = require '../src/codec.coffee'

describe 'codec', ->
  describe 'dec', ->
    it 'should parse a correct message', ->
      parsed = codec.dec '{"text": "hai", "author": "someone"}'
      assert.equal parsed.text, 'hai'
      assert.equal parsed.author, 'someone'

    it 'should fill in an author', ->
      parsed = codec.dec 'I am a non-json message'
      assert.equal parsed.author, 'unknown'

    it 'should place a non-json message in the text prop', ->
      parsed = codec.dec 'I am a non-json message'
      assert.equal parsed.text, 'I am a non-json message'

  describe 'co', ->
    it 'should encode a correct message', ->
      encoded = codec.co
        text: 'hai'
        author: 'there'
      assert.equal encoded, '{"text":"hai","author":"there"}'

    it 'should reject a message without text', ->
      assert.throws codec.co
        author: 'there'

    it 'should reject a message without an author', ->
      assert.throws codec.co
        text: 'hai'
