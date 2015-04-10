{EventEmitter} = require 'events'

class ShowQuote extends EventEmitter
  constructor: ->
    this.on 'tweet', (process, user, subject, data, storage) ->
      if data.quoted_status_id
        this.addQuote(process, data)
      process.done()

  addQuote: (process, data) ->
    process.message = this.chopQuoteUrl(process.message, data.quoted_status.user.screen_name, data.quoted_status_id_str) + this.quoteMessage(data.quoted_status.user.screen_name, data.quoted_status.text)

  chopQuoteUrl: (message, screen_name, id_str) ->
    message.replace(" https://twitter.com/#{screen_name}/status/#{id_str}", '')

  quoteMessage: (screen_name, text) ->
    " 14Q> #{screen_name}: " +
      text.split('\n').map((line) ->
        "14#{line}"
      ).join('\n')

module.exports.showQuote = new ShowQuote
