path = require 'path'
fs = require 'fs'
_ = require 'underscore'
async = require 'async'
{EventEmitter} = require 'events'

class Processed extends EventEmitter
  constructor: ->
    @channels = []
    @user = ''
    @message = ''

    this.on 'commit', (data) =>
      @channels = data.channels
      @user = data.user
      @message = data.message

class PluginManager extends EventEmitter
  constructor: (@dir) ->
    @plugins = {}
    index = require path.join(@dir,'index')
    index.forEach (file) =>
      _.each require(path.join(@dir,path.basename(file, '.coffee','.js'))), (plugin, name) =>
        @plugins[name] =  plugin

    this.on 'process', (event, data..., callback) =>
      processed = new Processed
      async.series _.map(@plugins, (plugin) ->
        -> plugin.emit(event, processed, data...)
      ), callback(processed)

module.exports = PluginManager
