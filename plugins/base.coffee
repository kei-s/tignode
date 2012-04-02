{EventEmitter} = require 'events'

class Base extends EventEmitter
  constructor: ->
    this.on 'start', (response, user, ircd, stream) ->
      ircd.join(user, '#twitter')

    this.on 'tweet', (response, user, subject, data) ->
      response.channels.push '#twitter'
      response.user = user
      response.message = subject

module.exports = new Base
