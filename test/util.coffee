assert = require 'assert'
util = require '../src/util.coffee'

describe 'util', ->
  describe 'validator', ->
    it 'should demand a sync property', ->
      assert.equal util.validate({}).message, 'No sync property'
    it 'should demand a sync property that looks vaguely like a URL', ->
      assert.equal util.validate({sync: 'foo'}).message, 'Invalid sync target'
    it 'should pass on valid input', ->
      assert !util.validate
        sync: 'http://example.com'
