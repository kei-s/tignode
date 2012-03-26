{Server} = require 'ircdjs/lib/server'
{User} = require 'ircdjs/lib/user'

class Ircd
  constructor: (@config, @twitter) ->
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

    @server.channels.message user, @server.channels.find(channelName), message

  install_event_handler: ->
    @server.events.on "PRIVMSG", (user, target, message) =>
      console.log message
      console.log @twitter.options
      @twitter.post '/statuses/update.json', { status: message }, (data) ->
        console.log data

  start: ->
    this.install_event_handler()
    @server.start()

module.exports = Ircd
