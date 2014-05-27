{EventEmitter} = require 'events'

class ExpandMedia extends EventEmitter
  constructor: ->
    ['tweet', 'retweet'].forEach (event) =>
      this.on event, (process, user, subject, data) =>
        if data.entities.media?
          this.expand_media(process, data.entities.media)
        else
          process.done()

  expand_media: (process, media) ->
    media.forEach (data) ->
      if data.media_url?
        process.message = process.message.replace(data.url, data.media_url)
    process.done()

module.exports.expandMedia = new ExpandMedia
