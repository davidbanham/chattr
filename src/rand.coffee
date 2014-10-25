module.exports =
  secret: ->
    return Math.random().toString(36).slice(-(Math.floor(Math.random() * 7) + 10))
