{User} = require 'ircdjs/lib/user'

class Stream
  constructor: (@ircd, @twitter)->

  respond: {
    text: (data) ->
      {
        user: data.user.screen_name,
        message: data.text
      }
    retweet: (data) ->
      {
        user: data.user.screen_name,
        message: "♻ " + data.text
      }
    favorite: (data) ->
      {
        user: data.source.screen_name,
        message: "★Fav: #{data.target_object.text}"
      }
    unfavorite: (data) ->
      {
        user: data.source.screen_name,
        message: "☆Unfav: #{data.target_object.text}"
      }
    follow: (data) ->
      {
        user: data.source.screen_name,
        message: "Start following"
      }
    list_member_added: (data) ->
      {
        user: data.source.screen_name,
        message: "List Member Added: #{data.target_object.slug}"
      }
    list_member_removed: (data) ->
      {
        user: data.source.screen_name,
        message: "List Member Removed: #{data.target_object.slug}"
      }
    direct_message: (data) ->
      {
        user: data.direct_message.sender.screen_name
        message: "DM"
      }
  }

  filter: (data) ->
    if data.text
      if data.retweeted_status
        this.respond.retweet(data)
      else
        this.respond.text(data)
    else if data.event
      switch data.event
        when 'list_member_added'
          this.respond.list_member_added(data)
        when 'list_member_removed'
          this.respond.list_member_added(data)
        when 'follow'
          this.respond.follow(data)
        when 'favorite'
          this.respond.favorite(data)
        when 'unfavorite'
          this.respond.unfavorite(data)
    else if data.friends
      # no use
    else if data.delete
      # no use
    else if data.direct_message
      this.respond.direct_message(data)

  start: (user) ->
    @user = user
    @ircd.join(@user, '#twitter')
    @twitter.stream 'user', (stream) =>
      stream.on 'data', (data) =>
        response = this.filter(data)
        console.log response
        return unless response
        @ircd.message response.user, '#twitter', response.message

module.exports = Stream
