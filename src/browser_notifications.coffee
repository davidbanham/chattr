Notification.requestPermission()

skips = {}

module.exports =
  skip: (conversation_name) ->
    skips[conversation_name] = true
  say: (conversation_name) ->
    if skips[conversation_name]
      delete skips[conversation_name]
      return
    new Notification "New message in #{conversation_name}", {tag: conversation_name}
