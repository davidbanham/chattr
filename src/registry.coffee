EventEmitter = require('events').EventEmitter

searchesDoc =
  _id: '_design/conversations'
  views:
    all:
      map: (
          (doc) ->
            return if !doc.name
            emit doc._id
        ).toString()
    by_invitee:
      map: (
          (doc) ->
            return if !doc.invitees
            emit invitee for invitee in doc.invitees
        ).toString()

Registry = (pouch) ->
  pouch = if PouchDB? then PouchDB else require 'pouchdb'
  @pouch = new pouch 'registry',
    auto_compaction: true
  @pouch.put(searchesDoc).then =>
    @emit 'ready'
  .catch (err) =>
    @emit 'ready' if err.status is 409
  @register = (con, cb) =>
    @pouch.put con, con.name, cb
  @by_name = (name, cb) =>
    @pouch.get name, cb
  @by_invitee = (invitee, cb) =>
    @pouch.query 'conversations/by_invitee', {include_docs: true, key: invitee}, (err, res) ->
      return cb err if err
      cb null, res.rows.map (row) ->
        return row.doc
  @update = (con, cb) =>
    @pouch.get con.name, (err, doc) =>
      return cb err if err
      con._rev = doc._rev
      con._id = doc._id
      @pouch.put con, cb
  @all_conversations = (cb) =>
    @pouch.query 'conversations/all', {include_docs: true}, (err, res) ->
      return cb err if err
      cb null, res.rows.map (result) ->
        return result.doc

  return this

Registry.prototype = EventEmitter.prototype

module.exports = Registry
