EventEmitter = require('events').EventEmitter

searchesDoc =
  _id: '_design/by_invitee'
  views:
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
  @register = (con, cb) =>
    @pouch.put con, con.name, cb
  @by_name = (name, cb) =>
    @pouch.get name, cb
  @by_invitee = (invitee, cb) =>
    @pouch.query 'by_invitee', {include_docs: true, key: invitee}, (err, res) ->
      return cb err if err
      cb null, res.rows.map (row) ->
        return row.doc

  return this

Registry.prototype = EventEmitter.prototype

module.exports = Registry
