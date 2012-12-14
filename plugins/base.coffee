{EventEmitter} = require 'events'

class Base extends EventEmitter
  constructor: ->
    this.on 'start', (process, me, ircd, stream) ->
      ircd.join(me, '#twitter')
      process.done()

    this.on 'tweet', (process, user, subject, data) ->
      this.publish(process, user, subject)

    this.on 'retweet', (process, user, subject, data) ->
      this.publish(process, user, '♻ RT @'+data.retweeted_status.user.screen_name+': '+subject)

    this.on 'PRIVMSG', (process, me, message, channel, twitter, storage) ->
      # assign process.message for next plugins
      process.message = message
      process.done()

  publish: (process, user, subject) ->
    process.channels.push '#twitter'
    process.user = user
    process.message = subject
    process.done()

module.exports.base = new Base
