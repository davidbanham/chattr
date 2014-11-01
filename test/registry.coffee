assert = require 'assert'
random = require '../src/rand.coffee'

Registry = require '../src/registry.coffee'

reg = null
con = null

describe 'registry', ->

  beforeEach ->
    reg = new Registry random.secret()
    con =
      name: random.secret()
      secret: random.secret()
      invitees: [ random.secret(), random.secret(), random.secret() ]
  afterEach (done) ->
    reg.pouch.destroy done

  it 'should expose a pouch', ->
    # This doesn't form part of the public API. Just convenient for testing.
    assert reg.pouch
    assert reg.pouch.put

  describe 'register', ->
    it 'should register a given conversation', (done) ->
      reg.register con, (err) ->
        assert.deepEqual err, null
        reg.pouch.get con.name, (err, doc) ->
          assert.deepEqual err, null
          assert.equal doc._id, con.name
          assert.equal doc.secret, con.secret
          assert.deepEqual doc.invitees, con.invitees
          done()

  describe 'remove', ->
    it 'should remove a given conversation', (done) ->
      reg.register con, (err) ->
        assert.deepEqual err, null
        reg.remove con.name, (err) ->
          assert.deepEqual err, null
          reg.pouch.get con.name, (err, doc) ->
            assert.equal err.message, 'deleted'
            done()

  describe 'by_name', ->
    it 'should return conversation info by name', (done) ->
      reg.register con, (err) ->
        assert.deepEqual err, null
        reg.by_name con.name, (err, found) ->
          assert.deepEqual err, null
          assert.equal found._id, con.name
          assert.equal found.secret, con.secret
          assert.deepEqual found.invitees, con.invitees
          done()

  describe 'by_invitee', ->
    it 'should return conversation by an invitee', (done) ->
      reg.on 'ready', ->
        reg.register con, (err) ->
          assert.deepEqual err, null
          reg.by_invitee con.invitees[1], (err, found) ->
            assert.deepEqual err, null
            assert Array.isArray found
            assert.equal found[0]._id, con.name
            assert.equal found[0].secret, con.secret
            assert.deepEqual found[0].invitees, con.invitees
            done()

  describe 'update', ->
    it 'should allow you to add more invitees', (done) ->
      reg.register con, (err) ->
        assert.deepEqual err, null
        con.invitees.push random.secret()
        reg.update con, (err) ->
          assert.deepEqual err, null
          reg.pouch.get con.name, (err, doc) ->
            assert.deepEqual err, null
            assert.deepEqual doc.invitees, con.invitees
            done()

  describe 'all_conversations', ->
    it 'should return all conversations it knows about', (done) ->
      outerName = con.name
      reg.register con, (err) ->
        assert.deepEqual err, null
        con.name = random.secret()
        reg.register con, (err) ->
          assert.deepEqual err, null
          reg.all_conversations (err, found) ->
            assert.deepEqual err, null
            assert.equal found.length, 2
            names = [outerName, con.name]
            match = 0
            for name in names
              for row in found
                match++ if name is row.name
            assert.equal match, names.length
            done()
