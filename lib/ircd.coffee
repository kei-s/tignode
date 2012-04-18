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
    @server.events.on "PRIVMSG", (user, target, message) =>
      @pluginManager.process 'PRIVMSG', user, message, target, (processed) =>
        @twitter.post '/statuses/update.json', { status: processed.message }, (data) =>
          console.log data

  start: ->
    this.install_event_handler()
    @server.start()

module.exports = Ircd
