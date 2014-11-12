Conversation = require './convo.coffee'
crypt = require './crypt.coffee'
util = require './util.coffee'
random = require './rand.coffee'
elements = require './elements.coffee'
Registry = require './registry.coffee'

React = require 'react'

ConversationForm = React.createClass
  displayName: 'ConversationForm'

  parentName: random.name()

  newName: ->
    @parentName = random.name()
    @setProps()

  handleSubmit: (e) ->
    e.preventDefault()
    create_conversation {sync: 'http://example.com'}, (err) ->
      populate_list()
    name = @refs.author.getDOMNode().value.trim()

  render: ->
    return React.DOM.form {onSubmit: @handleSubmit}, elements.Input({name: 'name', value: @parentName}), elements.Input({name: 'sync', value: 'http://example.com'}), elements.Button({action: @newName, text: 'Reset Name'}), elements.Button({text: 'Submit'})

List = React.createClass
  render: ->
    items = []
    for conversation in @props.conversations
      do (conversation) =>
        items.push elements.Item {name: conversation.name}
        items.push elements.Button {text: 'X', action: =>
          reg.remove conversation.name, (err) =>
            console.error err if err
            con = new Conversation conversation.name, 'http://localhost'
            con.destroy (err) =>
              console.error err if err
              populate_list()
        }
    return React.DOM.ul null, items

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

populate_list = ->
  reg.all_conversations (err, conversations) ->
    return alert err if err
    React.renderComponent List(conversations: conversations), document.getElementById 'list'

populate_list()