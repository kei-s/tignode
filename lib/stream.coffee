{User} = require 'ircdjs/lib/user'

class Stream
  constructor: (@ircd, @twitter, @pluginManager) ->
    @stream = this

  filter: (data) ->
    if data.text
      if data.retweeted_status
        { event: 'retweet', user: data.user.screen_name, subject: data.text }
      else
        { event: 'tweet', user: data.user.screen_name, subject: data.text }
    else if data.event
      switch data.event
        when 'list_member_added', 'list_member_removed'
          { event: data.event, user: data.source.screen_name, subject:  data.target_object.slug }
        when 'favorite', 'unfavorite'
          { event: data.event, user: data.source.screen_name, subject: data.target_object.text }
        when 'follow'
          { event: 'follow', user: data.source.screen_name }
    else if data.friends
      # no use
    else if data.delete
      # no use
    else if data.direct_message
      { event: 'direct_message', user: data.direct_message.sender.screen_name, subject: data.direct_message.text }

  read: (data) ->
    response = this.filter(data)
    return unless response
    @pluginManager.process response.event, response.user, response.subject, data, (processed) =>
      (processed.channels || []).forEach (channel) =>
        @ircd.message processed.user, channel, processed.message

  start: (user) ->
    @pluginManager.process 'start', user, @ircd, this, =>
      console.log 'stream start'
      @twitter.stream 'user', (stream) =>
        stream.on 'data', (data) =>
          this.read(data)

module.exports = Stream
