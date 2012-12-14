{EventEmitter} = require 'events'

class Update extends EventEmitter
  constructor: ->
    this.on 'PRIVMSG', (process, me, message, channel, twitter, storage) ->
      if process.message
        twitter.post '/statuses/update.json', { status: process.message }, (data) =>
          console.log data
      process.done()

module.exports.update = new Update
