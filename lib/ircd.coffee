_ = require 'underscore'
OAuth = require 'oauth'
{Server} = require 'ircdjs/lib/server'
{User} = require 'ircdjs/lib/user'

class Ircd
  constructor: (@config, @twitter, @pluginManager, @storage, @tignode) ->
    @server = new Server
    @server.config = @config
    @events = @server.events
    @oauth = new OAuth.OAuth('https://api.twitter.com/oauth/request_token',
                             'https://api.twitter.com/oauth/access_token',
                             @twitter.options.consumer_key,
                             @twitter.options.consumer_secret,
                             '1.0A', null, 'HMAC-SHA1');

  join: (user, channelName) ->
    @server.channels.join(user, channelName)
    @server.channels.find(channelName)

  register: (nick) ->
    unless user = @server.users.find(nick)
      user = new User(null, @server)
      user.nick = nick
      @server.users.register(user)
    user

  message: (nick, channelName, message) ->
    user = @server.users.find(nick) || do =>
      u = new User(null, @server)
      u.nick = nick
      u

    message.split("\n").forEach (line) =>
      @server.channels.message user, @server.channels.find(channelName), line

  noticeAll: (user, message, excepts=[]) ->
    _.chain(@server.channels.registered).map((channel,name) ->
      return name
    ).reject((name) ->
      _.include excepts, name
    ).value().forEach (name) ->
      user.send user.mask, 'NOTICE', name, ':' + message

  installCommandHandler: ->
    originalCommands = {}
    for command in ['PRIVMSG', 'JOIN', 'PART', 'INVITE', 'KICK']
      originalCommands[command] = @server.commands[command]

    @server.commands['PRIVMSG'] = (me, target, message) =>
      if target == '#welcome'
        # on PIN Code
        verifier = message
        @oauth.getOAuthAccessToken @token, @token_secret, verifier, (err, access_token_key, access_token_secret, results) =>
          @access_token.save {
            access_token_key: access_token_key,
            access_token_secret: access_token_secret
          }
          @twitter.options.access_token_key = access_token_key
          @twitter.options.access_token_secret = access_token_secret
          @tignode.start_stream(me)
      else if message[0] == '\u0001' && message.lastIndexOf('\u0001') > 0
        # parse CTCP message
        regexp = /\u0001([^\u0001]*)\u0001/g
        while (matched = regexp.exec message)?
          ctcp_message = matched[1].replace(/\u0010n/g,'\n')
                                   .replace(/\u0010r/g,'\r')
                                   .replace(/\u0010\u0030/g,'\u0000')
                                   .replace(/\u0010\u0010/g,'\u0010')
                                   .replace(/\\a/g,'\u0001')
                                   .replace(/\\\\/g, '\\')
          [type, texts...] = ctcp_message.split(' ')
          text = texts.join(' ')
          @pluginManager.process 'CTCP', me, type, text, target, @twitter, @storage, @, (processed) =>
            originalCommands['PRIVMSG'].apply(@server.commands, [me, target, processed.message])
      else
        # normal message
        @pluginManager.process 'PRIVMSG', me, message, target, @twitter, @storage, @, (processed) =>
          originalCommands['PRIVMSG'].apply(@server.commands, [me, target, processed.message])

    @server.commands['JOIN'] = (me, channelNames) =>
      @pluginManager.process 'JOIN', me, channelNames.split(','), (processed) =>
        originalCommands['JOIN'].apply(@server.commands, [me, channelNames])

    @server.commands['PART'] = (me, channelName, partMessage) =>
      @pluginManager.process 'PART', me, channelName, partMessage (processed) =>
        originalCommands['PART'].apply(@server.commands, [me, channelName, partMessage])

    @server.commands['INVITE'] = (me, nick, channelName) =>
      user = this.register(nick)
      this.join(user, channelName)
      @pluginManager.process 'INVITE', me, nick, channelName, (processed) =>
        originalCommands['INVITE'].apply(@server.commands, [me, nick, channelName])

    @server.commands['KICK'] = (me, channels, users, kickMessage) =>
      @pluginManager.process 'KICK', me, channels.split(','), users.split(','), kickMessage, (processed) =>
        originalCommands['KICK'].apply(@server.commands, [me, channels, users, kickMessage])

  register_oauth: (user, access_token) ->
    this.join(user, '#welcome')
    @oauth.getOAuthRequestToken (err, token, token_secret, parsedQueryString) =>
      @token = token
      @token_secret = token_secret
      @access_token = access_token
      authorize_url = 'https://api.twitter.com/oauth/authorize?oauth_token=' + token
      this.message 'tignode', '#welcome', "Please approve me at #{authorize_url}"
      this.message 'tignode', '#welcome', "And input PIN code here"

  start: ->
    this.installCommandHandler()
    @server.start()

module.exports = Ircd
