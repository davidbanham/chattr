module.exports =
  validate: (opts) ->
    return new Error 'No sync property' if !opts.sync
    return new Error 'Invalid sync target' if opts.sync.substring(0, 4) isnt 'http'
    return null
