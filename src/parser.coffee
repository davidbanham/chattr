module.exports =
  parse: (input) ->
    try
      parsed = JSON.parse input
    catch
      parsed =
        text: input
        author: 'unknown'
    return parsed
