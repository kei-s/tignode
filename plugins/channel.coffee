_ = require 'underscore'
Config = require '../lib/config'
{EventEmitter} = require 'events'

class Channel extends EventEmitter
  constructor: ->
    @channels = new Config('channels')

    this.on 'start', (process, me, ircd, stream) ->
      _.chain(@channels.data).map((channels) ->
        channels
      ).flatten().uniq().each (channel) ->
        ircd.join(me, channel)

      _.each @channels.data, (channels, nick) ->
        user = ircd.register(nick)
        _.each channels, (channel) ->
          ircd.join(user, channel)
      process.done()

    this.on 'JOIN', (process, me, channelNames) ->
      process.done()

    this.on 'PART', (process, me, channelName, partMessage) ->
      process.done()

    this.on 'INVITE', (process, me, nick, channelName) ->
      @channels.update (data) =>
        data[nick] ||= []
        data[nick].push(channelName)
        data[nick] = _.uniq(data[nick])

      process.done()

    this.on 'KICK', (process, me, channels, users, kickMessage) ->
      process.done()

    this.on 'tweet', (process, user, subject, data) ->
      this.sayToChannel(process, user)

    this.on 'retweet', (process, user, subject, data) ->
      this.sayToChannel(process, user)

  sayToChannel: (process, user) ->
    unless _.isEmpty @channels.data[user]
      process.channels.push @channels.data[user]...
    process.done()

module.exports.channel = new Channel
