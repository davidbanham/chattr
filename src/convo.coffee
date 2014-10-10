EventEmitter = require('events').EventEmitter

Conversation = (name, syncTarget, pouch) ->
  throw new Error 'syncTarget is required' if !syncTarget
  PouchDB = pouch or require 'pouchdb'
  @name = name
  @pouch = new PouchDB name,
    auto_compaction: true
  @pouch.sync syncTarget,
    live: true
  @write = (msg, cb) =>
    @pouch.post {time: new Date().toISOString(), message: msg}, cb
  @read = (limit, cb) =>
    if typeof limit is 'function'
      cb = limit
      limit = 20
    @pouch.allDocs
      include_docs: true
      limit: limit
    , (err, res) ->
      return cb err if err
      return cb null, res.rows.map (row) ->
        return row.doc
  @changes = @pouch.changes({live: true}).on 'change', =>
    @emit 'message'
  return this

Conversation.prototype = EventEmitter.prototype

module.exports = Conversation
