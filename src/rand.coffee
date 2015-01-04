adjectives = require '../lib/adjectives.json'
animals = require '../lib/animals.json'
chars = ' !"#$%&\'()*+,-.0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_`abcdefghijklmnopqrstuvwxyz{|}~'

rand_char = ->
  return chars.charAt Math.floor Math.random() * chars.length

rand_string = (len) ->
  s = ''

  while s.length < len
    s += rand_char()

  return s

module.exports =
  secret: ->
    return rand_string 23
  array_member: (arr) ->
    return arr[Math.floor(Math.random() * arr.length)]
  name: ->
    return "#{@array_member adjectives} #{@array_member animals}"
