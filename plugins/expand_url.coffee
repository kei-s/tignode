{EventEmitter} = require 'events'

class ExpandUrl extends EventEmitter
  constructor: ->
    @resolvers = []
    ['tweet', 'retweet'].forEach (event) =>
      this.on event, (response, user, subject, data) =>
        this.expand_url(response, data.entities.urls)

  expand_url: (response, urls) ->
    urls.forEach (data) =>
      if data.expanded_url
        response.message = response.message.replace(data.url, data.expanded_url)
        @resolvers.forEach (resolver) =>
          resolver.resolve(response, data)

module.exports.expandUrl = new ExpandUrl
