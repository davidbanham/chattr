random = require './rand.coffee'
React = require 'react'

Item = React.createClass
  render: ->
    return React.DOM.li null, @props.name

Button = React.createClass
  displayName: 'Button'

  render: ->
    return React.DOM.button
      onClick: @props.action
      type: 'button' if @props.action
    , @props.text

Input = React.createClass
  displayName: 'Input'

  render: ->
    return React.DOM.input
      type: "text"
      value: @props.value
      name: @props.name
      onChange: @props.onChange

List = React.createClass
  render: ->
    items = []
    for thing in @props.model
      do (thing) =>
        items.push Item name: thing.name
        items.push Button text: 'X', action: thing.action

    return React.DOM.ul null, items

module.exports =
  Input: Input
  Button: Button
  Item: Item
  List: List
