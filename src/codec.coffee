module.exports =
  co: (container) ->
    encoded =
      text: container.text
      author: container.author
    return JSON.stringify encoded

  dec: (input) ->
    try
      parsed = JSON.parse input
    catch
      parsed =
        text: input
        author: 'unknown'
    return parsed
