path = require 'path'
fs = require 'fs'
_ = require 'underscore'

class PluginManager
  constructor: (@dir) ->
    @plugins = {}
    index = require path.join(@dir,'index')
    index.forEach (file) =>
      _.each require(path.join(@dir,path.basename(file, '.coffee','.js'))), (plugin, name) =>
        @plugins[name] =  plugin

  add: (plugin) ->

  process: (event, data...) ->
    processed = { channels: [], message: '' }
    _.each @plugins, (plugin) ->
      plugin.emit(event, processed, data...)
    processed

module.exports = PluginManager
