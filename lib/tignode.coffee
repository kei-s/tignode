_ = require 'underscore'
fs = require 'fs'
path = require 'path'

{UserDatabase} = require 'ircdjs/lib/storage'
Twitter = require 'twitter'
Ircd = require './ircd'
Storage = require './storage'
Stream = require './stream'
Config = require './config'
PluginManager = require './plugin_manager'

class TigNode
  constructor: ->
    @tignode = this
    @config = this.config()
    @access_token = new Config('access_token')
    @twitter = new Twitter(_.extend(@config.twitter,{
      access_token_key: @access_token.data.access_token_key,
      access_token_secret: @access_token.data.access_token_secret
      rest_base: 'https://api.twitter.com/1.1',
      user_stream_base: 'https://userstream.twitter.com/1.1',
    }))
    @pluginManager = new PluginManager(path.join(__dirname,'plugins'))
    @storage = new Storage(@config.storage)
    @ircd = new Ircd(@config.ircd, @twitter, @pluginManager, @storage, @tignode)
    @stream = new Stream(@ircd, @twitter, @pluginManager, @storage)
    @ircd.register('tignode')

  config: ->
    file = path.join __dirname,'..','config','config.json'
    JSON.parse(fs.readFileSync(file).toString())

  start_stream: (user) ->
    @stream.start(user)


  registration: ->
    tignode = this
    UserDatabase.prototype._register = UserDatabase.prototype.register
    UserDatabase.prototype.register = (user, username, hostname, servername, realname) ->
      _user = user
      this._register(user, username, hostname, servername, realname)
      if user.registered
        _.bind( ->
          if @twitter.options.access_token_key && @twitter.options.access_token_secret
            start_stream(user)
          else
            @ircd.register_oauth(user, @access_token)
        , tignode)()

  start: ->
    @tignode.registration()
    @ircd.start()
    console.log 'tignode start'

exports.run = ->
  # start
  tignode = new TigNode
  tignode.start()

  # signal for debug
  process.on 'SIGUSR2', ->
    console.log _.map tignode.storage.cache.map, (data, key) ->
      [
        key,
        data.id,
        data.in_reply_to_status_id,
        data.user.screen_name,
        data.text
      ].join()
