{EventEmitter} = require 'events'

class Base extends EventEmitter
  constructor: ->
    this.on 'start', (response, user, ircd, stream) ->
      ircd.join(user, '#twitter')

    this.on 'tweet', (response, user, subject, data) ->
      response = this.publish(response, user, subject)

    this.on 'retweet', (response, user, subject, data) ->
      response = this.publish(response, user, '♻ '+subject)

  publish: (response, user, subject) ->
    response.channels.push '#twitter'
    response.user = user
    response.message = subject
    response

module.exports.base = new Base
