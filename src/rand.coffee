chars = ' !"#$%&\'()*+,-.0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ^_`abcdefghijklmnopqrstuvwxyz{|}~'
bandname = require 'bandname'

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
  name: bandname
