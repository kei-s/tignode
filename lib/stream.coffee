Storage = require './storage'
{User} = require 'ircdjs/lib/user'

class Stream
  constructor: (@ircd, @twitter, @pluginManager, @storage) ->

  filter: (data) ->
    if data.text
      if data.retweeted_status
        { event: 'retweet', user: data.user.screen_name, subject: data.retweeted_status.text }
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

  read: (data, me) ->
    response = this.filter(data)
    return unless response
    typableId = @storage.store(data)
    @pluginManager.process response.event, response.user, response.subject, data, @storage, typableId, (processed) =>
      (processed.channels || []).forEach (channel) =>
        if processed.user == me.nick
          console.log processed.message
          console.log processed.message.replace(/(?:\d{1,2})?/g,"")
          @ircd.noticeAll me, processed.message.replace(/(?:\d{1,2})?/g,"")
        else
          @ircd.message processed.user, channel, processed.message

  start: (user) ->
    @pluginManager.process 'start', user, @ircd, this, =>
      console.log 'stream start'
      @twitter.stream 'user', (stream) =>
        stream.on 'data', (data) =>
          this.read(data, user)

module.exports = Stream
