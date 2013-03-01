_ = require 'underscore'
TypableMap = require './typablemap'

class Storage
  constructor: (@config) ->
    @cache = new TypableMap(@config.typablemap)

  store: (data) ->
    return unless data.id
    @cache.push(data)

  getByStatusId: (statusId) ->
    _.find @cache.map, (data) ->
      data.id == statusId

  getByTypableId: (typablId) ->
    @cache.get(typablId)

module.exports = Storage
