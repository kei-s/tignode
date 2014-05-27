Storage = require './storage'
{User} = require 'ircdjs/lib/user'
{EventEmitter} = require 'events'

class Stream extends EventEmitter
  constructor: (@ircd, @twitter, @pluginManager, @storage) ->
    @numReceived = 0
    @lastReceived = new Date()
    @numRetry = 0
    @stallSec = 60 * 5
    @connected = false

  filter: (data) ->
    if data.text
      if data.retweeted_status
        { event: 'retweet', user: data.user.screen_name, subject: data.retweeted_status.text }
      else
        { event: 'tweet', user: data.user.screen_name, subject: data.text }
    else if data.event
      switch data.event
        when 'list_member_added', 'list_member_removed'
          { event: data.event, user: data.source.screen_name, subject: data.target_object.slug }
        when 'favorite', 'unfavorite'
          { event: data.event, user: data.source.screen_name, subject: data.target_object.text }
        when 'follow'
          { event: 'follow', user: data.source.screen_name }
    else if data.friends
      # no use
    else if data.delete
      # no use
    else if data.direct_message
      { event: 'direct_message', user: data.direct_message.sender.screen_name, subject: data.direct_message.text }

  read: (data, me) ->
    response = this.filter(data)
    return unless response
    typableId = @storage.store(data)
    @pluginManager.process response.event, response.user, response.subject, data, @storage, typableId, (processed) =>
      (processed.channels || []).forEach (channel) =>
        if processed.user == me.nick
          console.log processed.message
          console.log processed.message.replace(/(?:\d{1,2})?/g,"")
          @ircd.noticeAll me, processed.message.replace(/(?:\d{1,2})?/g,"")
        else
          @ircd.message processed.user, channel, processed.message

  start: (user) ->
    @pluginManager.process 'start', user, @ircd, this, =>
      console.log 'stream start'
      this.connect(user)
      @lastChecked = new Date()
      setInterval(this.monitor, 2*1000)

    @on 'receive', (data) =>
      @numReceived += 1
      @lastReceived = new Date()
      @numRetry = 0
      if data.created_at
        t = Date.parse(data.created_at)
        if !@mostRecent || @mostRecent < t
          @mostRecent = t

    @on 'reconnect', =>
      wait = 1000 * Math.pow(2, @numRetry)
      console.log "Reconnecting: #{@numRetry} times, wait: #{wait}"
      @numRetry += 1
      setTimeout =>
        this.connect(user)
      , wait

    @on 'status', (status) =>
      console.info "#{@numReceived} tweets, #{status.tps.toFixed(1)} TPS, delay: #{status.delay.toFixed(1)} s, last: #{status.last.toFixed(1)} s"

    @on 'end', (message) =>
      console.log "[STREAM:END] #{message}"
      @connected = false
      @stream.destroy()
      @emit 'reconnect'

  connect: (user) ->
    @twitter.stream 'user', (stream) =>
      @stream = stream
      stream.on 'data', (data) =>
        @connected = true
        this.read(data, user)
        @emit 'receive', data
      stream.on 'error', (error) =>
        @emit 'end', "ERROR #{error}"
      stream.on 'end', (response) =>
        if @connected
          @emit 'end', 'END'
      setTimeout =>
        unless @connected
          console.log 'Timeout in connect'
      , @stallSec + 30

  monitor: =>
    now = new Date()
    last = (now - @lastReceived) / 1000
    delta = (now - @lastChecked) / 1000
    tps = @numReceived / delta
    delay = (now - @mostRecent) / 1000
    status =
      tps: tps
      delay: delay
      last: last
      numReceived: @numReceived
      from: @lastChecked
      to: now

    if @connected
      @emit 'status', status

    if @connected && last > @stallSec
      @emit 'end', 'NO RESPONSE'

    @numReceived = 0
    @lastChecked = new Date()

module.exports = Stream
