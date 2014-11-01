adjectives = require '../lib/adjectives.json'
animals = require '../lib/animals.json'

module.exports =
  secret: ->
    return Math.random().toString(36).slice(-(Math.floor(Math.random() * 7) + 10))
  array_member: (arr) ->
    return arr[Math.floor(Math.random() * arr.length)]
  name: ->
    return "#{@array_member adjectives} #{@array_member animals}"
