_ = require 'underscore'
fs = require 'fs'
path = require 'path'

{Server} = require 'ircdjs/lib/server'
{User} = require 'ircdjs/lib/user'
Twitter = require 'twitter'

class TigNode
  constructor: ->
    tignode = this
    @tignode = this
    file = path.join __dirname,'..','config','config.json'
    @config = JSON.parse(fs.readFileSync(file).toString())
    @server = new Server
    @server.config = @config.ircd
    @twitter = new Twitter(@config.twitter)
    @admin = new User(null, @server)
    @admin.nick = "tignode"
    @server.users.register(@admin)

    # registration
    User.prototype._register = User.prototype.register
    User.prototype.register = ->
      _user = this
      this._register()
      if this.registered
        _.bind( ->
          @user = _user
          if @twitter.options.access_token_key && @twitter.options.access_token_secret
            @tignode.start_stream()
          else
            @server.channels.join(_user, '#welcome')
            @twitter.oauth.getOAuthRequestToken (err, token, token_secret, parsedQueryString) =>
              # on PIN Code
              @server.events.once "PRIVMSG", (user, target, verifier) =>
                if user == _user && target == "#welcome"
                  @twitter.oauth.getOAuthAccessToken token, token_secret, verifier, (err, access_token, access_token_secret, results) =>
                    @twitter.options.access_token_key = access_token
                    @twitter.options.access_token_secret = access_token_secret
                    @tignode.start_stream()

              authorize_url = @twitter.options.authorize_url + '?oauth_token=' + token
              message = "Please approve me at #{authorize_url}"
              @server.channels.message @admin, @server.channels.find('#welcome'), message
              @server.channels.message @admin, @server.channels.find('#welcome'), "And input PIN code here"
        , tignode)()

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

  start_stream: ->
    @server.channels.join(@user, '#twitter')
    twitter_ch = @server.channels.find('#twitter')
    @twitter.stream 'user', (stream) =>
      stream.on 'data', (data) =>
        response = @tignode.filter(data)
        console.log response
        return unless response
        user = new User(null, @server)
        user.nick = response.user
        @server.channels.message user, twitter_ch, response.message

  start: ->
    @server.start()

exports.run = ->
  # start
  tignode = new TigNode
  tignode.start()

  # signal for debug
  process.on 'SIGUSR2', ->
    console.log(tignode.server.users.registered)
