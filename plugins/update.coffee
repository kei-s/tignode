{EventEmitter} = require 'events'

class Update extends EventEmitter
  constructor: ->
    this.on 'PRIVMSG', (process, user, message, target, ircd) ->
      process.message = message
      process.done()

module.exports.update = new Update
