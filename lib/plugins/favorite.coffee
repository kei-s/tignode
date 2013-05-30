_ = require 'underscore'
{EventEmitter} = require 'events'

class Favorite extends EventEmitter
  constructor: ->
    this.on 'CTCP', (process, me, type, text, channel, twitter, storage) ->
      [command, typableIds...] = text.split(' ')
      if command == 'fav' || command == 'favorite'
        _.each typableIds, (typableId) ->
          data = storage.getByTypableId(typableId)
          twitter.post '/favorites/create.json', {id: data.id_str}, (response)->
            console.log response
      process.done()

module.exports.favorite = new Favorite
