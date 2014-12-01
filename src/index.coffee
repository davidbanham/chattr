Conversation = require './convo.coffee'
crypt = require './crypt.coffee'
util = require './util.coffee'
random = require './rand.coffee'
elements = require './elements.coffee'
Registry = require './registry.coffee'
EventEmitter = require('events').EventEmitter

React = require 'react'

dispatcher = new EventEmitter()

conversations_model = []

ConversationForm = React.createClass
  displayName: 'ConversationForm'

  getInitialState: ->
    sync: @props.sync or 'http://example.com'
    name: @props.name or random.name()

  componentWillReceiveProps: (props) ->
    @setState props

  newName: ->
    @setState({name: random.name()})

  handleSubmit: (e) ->
    e.preventDefault()
    create_conversation {sync: @state.sync, name: @state.name}, (err) ->
      dispatcher.emit 'new_conversation'

  changeHandlerFactory: (name) ->
    return (e) ->
      dispatcher.emit "#{name}_change", e.target.value

  render: ->

    ['name', 'sync'].forEach (thing) =>
      dispatcher.on "#{thing}_change", (val) =>
        changeset = {}
        changeset[thing] = val
        @setProps changeSet

    return React.DOM.form(
      {onSubmit: @handleSubmit}
      elements.Input({name: 'name', value: @state.name, onChange: @changeHandlerFactory('name')})
      elements.Input({name: 'sync', value: @state.sync, onChange: @changeHandlerFactory('sync')})
      elements.Button({action: @newName, text: 'Reset Name'})
      elements.Button({text: 'Submit'})
    )

create_conversation = (opts, cb) ->
  secret = opts.secret or random.secret()
  name = opts.name or random.name()

  validationErr = util.validate opts
  return cb validationErr if validationErr?

  con = new Conversation name, opts.sync
  reg.register {name: name, secret: secret, invitees: opts.invitees, syncTarget: opts.sync}, cb

reg = new Registry 'registry'

reg.on 'ready', ->
  React.renderComponent ConversationForm(), document.getElementById 'create_conversation'

populate_conversations = ->
  reg.all_conversations (err, conversations) ->
    return alert err if err
    conversations_model = conversations.map populater
    dispatcher.emit 'update_all_conversations', conversations

['new_conversation', 'ready', 'conversation_deleted'].forEach (event) ->
  dispatcher.on event, populate_conversations

conversation_list = React.renderComponent elements.List(), document.getElementById 'list'

populater = (conversation) ->
  conversation = new Conversation conversation.name, conversation.syncTarget
  conversation.on 'message', ->
    conversations_model = conversations_model.map unread_incrementer conversation
    dispatcher.emit 'update_all_conversations', conversations_model
  return conversation

deleter_factory = (name) ->
  return ->
    reg.remove name, (err) =>
      console.error err if err
      con = new Conversation name, 'http://localhost'
      con.destroy (err) =>
        console.error err if err
        dispatcher.emit 'conversation_deleted', name

representer = (conversation) ->
  name: conversation.name
  action: deleter_factory conversation.name
  classes:
    unread: conversation.unread

changer = (changed) ->
  (conversation) ->
    if changed.name is conversation.name
      conversation = changed
    return conversation

unread_incrementer = (target) ->
  (conversation) ->
    if target.name is conversation.name
      conversation.unread ?= 0
      conversation.unread++
    return conversation

dispatcher.on 'update_all_conversations', (conversations) ->
  conversation_list.replaceProps items: conversations.map representer

dispatcher.emit 'ready'
