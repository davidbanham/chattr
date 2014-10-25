assert = require 'assert'
Conversation = require '../src/convo.coffee'

rando = ->
  return Math.floor(Math.random() * (1 << 24)).toString(16)

con = null

describe 'conversation', ->
  beforeEach ->
    con = new Conversation rando(), 'http://example.com'
    con.on 'error', (err) ->
      throw err unless err.status is 502
  afterEach (done) ->
    con.removeAllListeners()
    con.pouch.destroy done
  it 'should hold a name', ->
    assert con.name
  it 'should expose a pouch', ->
    # This doesn't form part of the public API. Just convenient for testing.
    assert con.pouch
    assert con.pouch.put
  it 'should be an EventEmitter', ->
    assert con.on
  describe 'write', ->
    it 'should have a write method', ->
      assert con.write
    it 'should write documents into the database', (done) ->
      con.write 'ohai!', ->
        con.pouch.allDocs (err, res) ->
          done assert.equal res.total_rows, 1
    it 'should write properly formed documents into the database', (done) ->
      d = new Date().toISOString()
      con.write 'hello there', ->
        con.pouch.allDocs {include_docs: true}, (err, res) ->
          doc = res.rows[0].doc
          assert.equal doc.message, 'hello there'
          assert.equal doc.time, d
          done()
    it 'should emit a message event when a doc is written', (done) ->
      con.on 'message', ->
        done()
      con.write 'hai'
  describe 'read', ->
    it 'should have a read method', ->
      assert con.read
    it 'should return a document', (done) ->
      con.write 'hai', ->
        con.read (err, messages) ->
          assert.deepEqual err, null
          assert messages.length > 0
          done()
    it 'should return as many documents as you ask for', (done) ->
      for i in [1..20]
        con.write 'hai'+i
      con.read 10, (err, messages) ->
        assert.deepEqual err, null
        done assert.equal messages.length, 10
    it 'should return 20 documents by default', (done) ->
      for i in [1..30]
        con.write 'hai'+i
      con.read (err, messages) ->
        assert.deepEqual err, null
        done assert.equal messages.length, 20
  it 'should demand a sync URL', ->
    err = null
    try
      innerCon = new Conversation rando()
    catch e
      err = e
    assert err
