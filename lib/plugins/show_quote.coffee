{EventEmitter} = require 'events'

class ShowQuote extends EventEmitter
  constructor: ->
    this.on 'tweet', (process, user, subject, data, storage) ->
      if data.quoted_status_id
        this.addQuote(process, data)
      process.done()

  addQuote: (process, data) ->
    process.message = process.message + this.quoteMessage(data.quoted_status.user.screen_name, data.quoted_status.text)

  quoteMessage: (screen_name, text) ->
    " 14Q> #{screen_name}: " +
      text.split('\n').map((line) ->
        "14#{line}"
      ).join('\n')

module.exports.showQuote = new ShowQuote
