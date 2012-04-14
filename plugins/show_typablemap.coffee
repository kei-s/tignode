{EventEmitter} = require 'events'

class ShowTypablemap extends EventEmitter
  constructor: ->
    this.on 'tweet', (process, user, subject, data, storage, typableId) ->
      this.addTypableId(process, typableId)
      process.done()

    this.on 'retweet', (process, user, subject, data, storage, typableId) ->
      this.addTypableId(process, typableId)
      process.done()

  addTypableId: (process, typableId) ->
    process.message = process.message + " 14(#{typableId})"

module.exports.showTypablemap = new ShowTypablemap
