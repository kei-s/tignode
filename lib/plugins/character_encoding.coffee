{EventEmitter} = require 'events'

class CharacterEncoding extends EventEmitter
  constructor: ->
    this.on 'tweet', (process) ->
      this.replace(process)
      process.done()

    this.on 'retweet', (process) ->
      this.replace(process)
      process.done()

  replace: (process) ->
    process.message= process.message.replace /&(amp|lt|gt);/g, (entity, code) ->
      {amp: "&", lt: "<", gt: ">"}[code]

module.exports.characterEncoding = new CharacterEncoding
