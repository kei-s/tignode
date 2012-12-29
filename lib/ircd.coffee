_ = require 'underscore'
{Server} = require 'ircdjs/lib/server'
{User} = require 'ircdjs/lib/user'

class Ircd
  constructor: (@config, @twitter, @pluginManager, @storage) ->
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

  installCommandHandler: ->
    originalCommands = {}
    for command in ['PRIVMSG', 'JOIN', 'PART', 'INVITE', 'KICK']
      originalCommands[command] = @server.commands[command]

    @server.commands['PRIVMSG'] = (me, target, message) =>
      return if target == '#welcome'
      if message[0] == '\u0001' && message.lastIndexOf('\u0001') > 0
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
          @pluginManager.process 'CTCP', me, type, text, target, @twitter, @storage, (processed) =>
            originalCommands['PRIVMSG'].apply(@server.commands, [me, target, processed.message])
      else
        @pluginManager.process 'PRIVMSG', me, message, target, @twitter, @storage, (processed) =>
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

  start: ->
    this.installCommandHandler()
    @server.start()

module.exports = Ircd
