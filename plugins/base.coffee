{EventEmitter} = require 'events'

class Base extends EventEmitter
  constructor: ->
    this.on 'start', (process, user, ircd, stream) ->
      ircd.join(user, '#twitter')
      process.done()

    this.on 'tweet', (process, user, subject, data) ->
      this.publish(process, user, subject)

    this.on 'retweet', (process, user, subject, data) ->
      this.publish(process, user, '♻ '+subject)

  publish: (process, user, subject) ->
    process.channels.push '#twitter'
    process.user = user
    process.message = subject
    process.done()

module.exports.base = new Base
