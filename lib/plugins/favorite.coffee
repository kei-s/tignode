_ = require 'underscore'
{EventEmitter} = require 'events'

class Favorite extends EventEmitter
  constructor: ->
    this.on 'CTCP', (process, me, type, text, channel, twitter, storage, ircd) ->
      [command, typableIds...] = text.split(' ')
      if command == 'fav' || command == 'favorite'
        _.each typableIds, (typableId) ->
          data = storage.getByTypableId(typableId)
          twitter.post '/favorites/create.json', {id: data.id_str}, (response)->
            ircd.noticeAll(me, "[Favorite] #{data.user.screen_name}: #{data.text}")
            console.log response
      process.done()

module.exports.favorite = new Favorite
