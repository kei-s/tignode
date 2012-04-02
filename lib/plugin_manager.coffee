path = require 'path'
fs = require 'fs'

class PluginManager
  constructor: (@dir) ->
    @plugins = []
    fs.readdirSync(@dir).forEach (file) =>
       @plugins.push require(path.join(@dir,path.basename(file, '.coffee','.js')))

  add: (plugin) ->

  process: (event, data...) ->
    processed = { channels: [], message: '' }
    @plugins.forEach (plugin) ->
      plugin.emit(event, processed, data...)
    processed

module.exports = PluginManager
