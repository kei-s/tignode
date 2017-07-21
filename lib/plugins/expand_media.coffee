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
    media.forEach (data) ->
      switch data.type
        when 'video', 'animated_gif'
          mp4_variant = _.max data.video_info.variants, (variant) ->
            if variant.content_type == 'video/mp4'
              variant.bitrate
            else
              -1
          process.message = process.message.replace(media[0].url, data.media_url + " " + mp4_variant.url)
        when 'photo'
          return
        else
          console.log data
          console.log data.video_info.variants

    if _.find(media, (data) -> data.type == 'photo')
      media_urls = _.map media, (data) ->
        data.media_url
      process.message = process.message.replace(media[0].url, media_urls.join(" "))

    process.done()

module.exports.expandMedia = new ExpandMedia
