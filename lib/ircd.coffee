_ = require 'underscore'
{Server} = require 'ircdjs/lib/server'
{User} = require 'ircdjs/lib/user'

class Ircd
  constructor: (@config, @twitter, @pluginManager) ->
    @server = new Server
    @server.config = @config
    @events = @server.events

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

  installEventHandler: ->
    @server.events.on "PRIVMSG", (me, target, message) =>
      return if target == '#welcome'
      @pluginManager.process 'PRIVMSG', me, message, target, (processed) =>
        @twitter.post '/statuses/update.json', { status: processed.message }, (data) =>
          console.log data

    @server.events.on "JOIN", (me, channelNames) =>
      @pluginManager.process 'JOIN', me, channelNames.split(','), (processed) =>

    @server.events.on "PART", (me, channelName, partMessage) =>
      @pluginManager.process 'PART', me, channelName, partMessage (processed) =>

    @server.events.on "INVITE", (me, nick, channelName) =>
      user = this.register(nick)
      this.join(user, channelName)
      @pluginManager.process 'INVITE', me, nick, channelName, (processed) =>

    @server.events.on "KICK", (me, channels, users, kickMessage) =>
      @pluginManager.process 'KICK', me, channels.split(','), users.split(','), kickMessage, (processed) =>

  start: ->
    this.installEventHandler()
    @server.start()

module.exports = Ircd
