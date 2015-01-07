_ = require 'underscore'
{EventEmitter} = require 'events'

class ExpandMedia extends EventEmitter
  constructor: ->
    ['tweet', 'retweet'].forEach (event) =>
      this.on event, (process, user, subject, data) =>
        if data.extended_entities?
          this.expand_media(process, data.extended_entities.media)
        else
          process.done()

  expand_media: (process, media) ->
    media_urls = _.map media, (data) ->
      data.media_url

    process.message = process.message.replace(media[0].url, media_urls.join(" "))
    process.done()

module.exports.expandMedia = new ExpandMedia
