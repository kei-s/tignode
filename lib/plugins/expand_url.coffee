{EventEmitter} = require 'events'

class ExpandUrl extends EventEmitter
  constructor: ->
    @resolvers = []
    ['tweet', 'retweet'].forEach (event) =>
      this.on event, (process, user, subject, data) =>
        this.expand_url(process, data.entities.urls)

  expand_url: (process, urls) ->
    urls.forEach (data) =>
      if data.expanded_url
        process.message = process.message.replace(data.url, data.expanded_url)
    process.done()

module.exports.expandUrl = new ExpandUrl
