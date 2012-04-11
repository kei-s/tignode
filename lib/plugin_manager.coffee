path = require 'path'
fs = require 'fs'
_ = require 'underscore'
async = require 'async'
{EventEmitter} = require 'events'

class Process
  constructor: (@event, @plugins, @data, @callback) ->
    @channels = []
    @user = ''
    @message = ''

  done: ->
    @current += 1
    unless @plugins[@current]
      return @callback(this)

    if @plugins[@current].listeners(@event).length != 0
      @plugins[@current].emit(@event, this, @data...)
    else
      this.done()

  start: ->
    @current = -1
    this.done()

class PluginManager
  constructor: (@dir) ->
    @plugins = {}
    index = require path.join(@dir,'index')
    index.forEach (file) =>
      _.each require(path.join(@dir,path.basename(file, '.coffee','.js'))), (plugin, name) =>
        @plugins[name] =  plugin

  process: (event, data..., callback) ->
    process = new Process(event, _.values(@plugins), data, callback)
    process.start()

module.exports = PluginManager
