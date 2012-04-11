_ = require 'underscore'
fs = require 'fs'
path = require 'path'

{User} = require 'ircdjs/lib/user'
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
    }))
    @pluginManager = new PluginManager(path.join(__dirname,'..','plugins'))
    @ircd = new Ircd(@config.ircd, @twitter, @pluginManager)
    @storage = new Storage(@config.storage)
    @stream = new Stream(@ircd, @twitter, @pluginManager, @storage)
    @ircd.register('tignode')

  config: ->
    file = path.join __dirname,'..','config','config.json'
    JSON.parse(fs.readFileSync(file).toString())

  registration: ->
    tignode = this
    User.prototype._register = User.prototype.register
    User.prototype.register = ->
      _user = this
      this._register()
      if this.registered
        _.bind( ->
          @user = _user
          if @twitter.options.access_token_key && @twitter.options.access_token_secret
            @stream.start(@user)
          else
            @ircd.join(_user, '#welcome')
            @twitter.oauth.getOAuthRequestToken (err, token, token_secret, parsedQueryString) =>
              # on PIN Code
              @ircd.events.once "PRIVMSG", (user, target, verifier) =>
                if user == _user && target == "#welcome"
                  @twitter.oauth.getOAuthAccessToken token, token_secret, verifier, (err, access_token, access_token_secret, results) =>
                    @access_token.save {
                      access_token_key: access_token,
                      access_token_secret: access_token_secret
                    }
                    @twitter.options.access_token_key = access_token
                    @twitter.options.access_token_secret = access_token_secret
                    @stream.start(@user)

              authorize_url = @twitter.options.authorize_url + '?oauth_token=' + token
              message = "Please approve me at #{authorize_url}"
              @ircd.message 'tignode', '#welcome', message
              @ircd.message 'tignode', '#welcome', "And input PIN code here"
        , tignode)()

  start: ->
    @tignode.registration()
    @ircd.start()

exports.run = ->
  # start
  tignode = new TigNode
  tignode.start()

  # signal for debug
  process.on 'SIGUSR2', ->
    console.log(tignode.storage.cache.map)
