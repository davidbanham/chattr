Notification.requestPermission()

module.exports =
  say: (conversation_name) ->
    new Notification "New message in #{conversation_name}", {tag: conversation_name}
