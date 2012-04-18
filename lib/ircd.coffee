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

  install_event_handler: ->
    @server.events.on "PRIVMSG", (me, target, message) =>
      @pluginManager.process 'PRIVMSG', me, message, target, (processed) =>
        @twitter.post '/statuses/update.json', { status: processed.message }, (data) =>

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
    this.install_event_handler()
    @server.start()

module.exports = Ircd
