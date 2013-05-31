_ = require 'underscore'
{EventEmitter} = require 'events'

class Reply extends EventEmitter
  constructor: ->
    this.on 'CTCP', (process, me, type, text, channel, twitter, storage, ircd) ->
      [command, typableId, message...] = text.split(' ')
      if command == 're' || command == 'reply'
        data = storage.getByTypableId(typableId)
        message = "@#{data.user.screen_name} " + message.join(' ')
        twitter.post '/statuses/update.json', { status: message, in_reply_to_status_id: data.id_str }, (response) =>
          console.log response
      process.done()

module.exports.reply = new Reply
