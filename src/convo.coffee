EventEmitter = require('events').EventEmitter

latestMessagesDoc =
  _id: '_design/latest'
  views:
    all:
      map: (
        (doc) ->
          emit doc.time
      ).toString()

Conversation = (name, syncTarget) ->
  throw new Error 'syncTarget is required' if !syncTarget
  pouch = if PouchDB? then PouchDB else require 'pouchdb'
  @name = name
  @pouch = new pouch name,
    auto_compaction: true
  @pouch.put(latestMessagesDoc).then =>
    @emit 'ready'
  @pouch.sync syncTarget,
    live: true
  .on 'error', (err) =>
    @emit 'error', err
  .catch -> #Discard bluebird errors, we get it in the line above
  @write = (msg, cb) =>
    @pouch.post {time: new Date().toISOString(), message: msg}, cb
  @read = (limit, cb) =>
    if typeof limit is 'function'
      cb = limit
      limit = 20
    @pouch.query 'latest/all',
      include_docs: true
      limit: limit
    , (err, res) ->
      return cb err if err
      return cb null, res.rows.map (row) ->
        return row.doc
  @changes = @pouch.changes({live: true}).on 'change', =>
    @emit 'message'
  @destroy = (cb) =>
    @pouch.destroy cb
  return this

Conversation.prototype = EventEmitter.prototype

module.exports = Conversation
