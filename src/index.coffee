Conversation = require './convo.coffee'
Crypt = require './crypt.coffee'
util = require './util.coffee'
random = require './rand.coffee'
elements = require './elements.coffee'
Registry = require './registry.coffee'
EventEmitter = require('events').EventEmitter

React = require 'react'

dispatcher = new EventEmitter()

conversations_model = []
active_conversation = null

changeHandlerFactory = (name) ->
  return (e) =>
    changeset = {}
    changeset[name] = e.target.value
    @setState changeset

ConversationForm = React.createClass
  displayName: 'ConversationForm'

  getInitialState: ->
    sync: @props.sync or 'http://example.com'
    name: @props.name or random.name()
    secret: @props.secret or random.secret()
    iv: @props.iv or random.secret()

  newName: ->
    @setState({name: random.name()})

  handleSubmit: (e) ->
    e.preventDefault()
    create_conversation {sync: @state.sync, name: @state.name, secret: @state.secret, iv: @state.iv}, (err) ->
      dispatcher.emit 'new_conversation'


  render: ->

    return React.DOM.form(
      {onSubmit: @handleSubmit}
      elements.Input({name: 'name', value: @state.name, onChange: changeHandlerFactory.call(this, 'name')})
      elements.Input({name: 'sync', value: @state.sync, onChange: changeHandlerFactory.call(this, 'sync')})
      elements.Input({name: 'secret', value: @state.secret, onChange: changeHandlerFactory.call(this, 'secret')})
      elements.Input({name: 'iv', value: @state.iv, onChange: changeHandlerFactory.call(this, 'iv')})
      elements.Button({action: @newName, text: 'Reset Name'})
      elements.Button({text: 'Submit'})
    )

ConversationView = React.createClass
  displayName: 'ConversationView'

  getInitialState: ->
    messages: []

  decrypter: (container) ->
    container.message = @props.conversation.crypt.dec container.message
    return container

  componentWillMount: ->
    @props.conversation.read 10, (err, messages) =>
      @setState {messages: messages.map @decrypter}

  componentWillUpdate: ->
    @props.conversation.read 10, (err, messages) =>
      @setState {messages: messages.map @decrypter}

  newMessage: ->
    @props.conversation.write @props.conversation.crypt.enc @state.message

  render: ->
    return React.DOM.span(
      null
      elements.Input({name: 'message', value: @state.message, onChange: changeHandlerFactory.call(this, 'message')})
      elements.Button({action: @newMessage, text: 'Send'})
      @state.messages.map (container) ->
        elements.Text({text: container.message})
    )

create_conversation = (opts, cb) ->
  secret = opts.secret or random.secret()
  iv = opts.iv or random.secret()
  name = opts.name or random.name()

  validationErr = util.validate opts
  return cb validationErr if validationErr?

  con = new Conversation name, opts.sync
  reg.register {name: name, secret: secret, iv: iv, invitees: opts.invitees, syncTarget: opts.sync}, cb

reg = new Registry 'registry'

reg.on 'ready', ->
  React.renderComponent ConversationForm(), document.getElementById 'create_conversation'

populate_conversations = ->
  reg.all_conversations (err, conversations) ->
    return alert err if err
    conversations_model = conversations.map populater
    dispatcher.emit 'update_all_conversations', conversations_model

['new_conversation', 'ready', 'conversation_deleted'].forEach (event) ->
  dispatcher.on event, populate_conversations

conversation_list = React.renderComponent elements.List(), document.getElementById 'list'

populater = (conv) ->
  conversation = new Conversation conv.name, conv.syncTarget
  conversation.crypt = new Crypt conv.secret, conv.iv
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

focus_factory = (conversation) ->
  return ->
    dispatcher.emit 'focus_conversation', conversation

representer = (conversation) ->
  name: conversation.name
  remove: deleter_factory conversation.name
  action: focus_factory conversation
  classes:
    unread: conversation.unread

changer = (changed) ->
  (conversation) ->
    if changed.name is conversation.name
      conversation = changed
    return conversation

unread_incrementer = (target) ->
  (conversation) ->
    if target.name is conversation.name and conversation.name isnt active_conversation?.name
      conversation.unread ?= 0
      conversation.unread++
    return conversation

dispatcher.on 'update_all_conversations', (conversations) ->
  conversation_list.replaceProps items: conversations.map representer
  conversations.forEach (conversation) ->
    return if active_conversation is null
    if conversation.name is active_conversation.name
      active_conversation = conversation
      dispatcher.emit 'focus_conversation', active_conversation

dispatcher.on 'focus_conversation', (conversation) ->
  conversation.unread = 0
  active_conversation = conversation
  React.renderComponent ConversationView(conversation: active_conversation), document.getElementById 'conversation_view'

dispatcher.emit 'ready'
