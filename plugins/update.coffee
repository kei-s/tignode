{EventEmitter} = require 'events'

class Update extends EventEmitter
  constructor: ->
    this.on 'PRIVMSG', (process, me, message, target) ->
      process.message = message
      process.done()

module.exports.update = new Update
