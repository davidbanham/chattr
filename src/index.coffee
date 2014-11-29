Conversation = require './convo.coffee'
crypt = require './crypt.coffee'
util = require './util.coffee'
random = require './rand.coffee'
elements = require './elements.coffee'
Registry = require './registry.coffee'
EventEmitter = require('events').EventEmitter

React = require 'react'

dispatcher = new EventEmitter()

ConversationForm = React.createClass
  displayName: 'ConversationForm'

  getInitialState: ->
    sync: 'http://example.com'
    name: random.name()

  newName: ->
    @setState({name: random.name()})

  handleSubmit: (e) ->
    e.preventDefault()
    create_conversation {sync: @state.sync, name: @state.name}, (err) ->
      dispatcher.emit 'new_conversation'

  changeHandlerFactory: (name) ->
    return (e) =>
      newState = {}
      newState[name] = e.target.value
      @setState newState

  render: ->
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
  reg.register {name: name, secret: secret, invitees: opts.invitees}, cb

reg = new Registry 'registry'

reg.on 'ready', ->
  React.renderComponent ConversationForm(), document.getElementById 'create_conversation'

dispatcher.on 'new_conversation', ->
  populate_list()

populate_list = ->
  reg.all_conversations (err, conversations) ->
    return alert err if err
    model = conversations.map (conversation) ->
      name: conversation.name
      action: ->
        reg.remove conversation.name, (err) =>
          console.error err if err
          con = new Conversation conversation.name, 'http://localhost'
          con.destroy (err) =>
            console.error err if err
            populate_list()
    React.renderComponent elements.List(model: model), document.getElementById 'list'

populate_list()
