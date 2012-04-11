TypableMap = require './typablemap'

class Storage
  constructor: (@config) ->
    @cache = new TypableMap(@config.typablemap)

  store: (data) ->
    @cache.push data

module.exports = Storage
