{EventEmitter} = require 'events'

class ShowReply extends EventEmitter
  constructor: ->
    this.on 'tweet', (process, user, subject, data, storage) ->
      if data.in_reply_to_status_id
        this.addReply(process, storage, data.in_reply_to_status_id)
      process.done()

    this.on 'retweet', (process, user, subject, data, storage) ->
      if data.retweeted_status.in_reply_to_status_id
        this.addReply(process, storage, data.retweeted_status.in_reply_to_status_id)
      process.done()

  addReply: (process, storage, in_reply_to_status_id) ->
    if data = storage.getByStatusId(in_reply_to_status_id)
      process.message = process.message + " 14>> #{data.user.screen_name}: #{data.text}"

module.exports.showreply = new ShowReply
