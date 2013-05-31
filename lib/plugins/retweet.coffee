_ = require 'underscore'
{EventEmitter} = require 'events'

class Retweet extends EventEmitter
  constructor: ->
    this.on 'CTCP', (process, me, type, text, channel, twitter, storage, ircd) ->
      [command, typableIds...] = text.split(' ')
      if command == 'rt' || command == 'retweet'
        _.each typableIds, (typableId) ->
          data = storage.getByTypableId(typableId)
          twitter.post "/statuses/retweet/#{data.id_str}.json", (response)->
            console.log response
      process.done()

module.exports.retweet = new Retweet
