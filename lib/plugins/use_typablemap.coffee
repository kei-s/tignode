{EventEmitter} = require 'events'

class UseTypablemap extends EventEmitter
  constructor: ->
    this.on 'PRIVMSG', (process, me, message, channel, twitter, storage) ->
      this.reply(process, message, twitter, storage)
      this.retweet(process, message, twitter, storage)
      this.favorite(process, message, twitter, storage)
      process.done()

  reply: (process, message, twitter, storage) ->
    if false
      process.message = ''

  retweet: (process, message, twitter, storage) ->
    if false
      process.message = ''

  favorite: (process, message, twitter, storage) ->
    if false
      process.message = ''

module.exports.useTypablemap = new UseTypablemap
