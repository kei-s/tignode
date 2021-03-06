path = require 'path'
fs = require 'fs'

class Config
  constructor: (@name) ->
    @file = path.join __dirname,'..','config',"#{@name}.json"
    if fs.existsSync(@file)
      @data = JSON.parse(fs.readFileSync(@file).toString())
    else
      @data = {}

  update: (callback) ->
    callback(@data)
    this.save(@data)

  save: (data)->
    @data = data
    fs.writeFileSync(@file, JSON.stringify(@data))

module.exports = Config
