fs = require 'fs'
path = require 'path'

class Config
  constructor: (@name) ->
    @file = path.join __dirname,'..','config',"#{@name}.json"
    if path.existsSync(@file)
      @data = JSON.parse(fs.readFileSync(@file).toString())
    else
      @data = {}

  save: (data)->
    @data = data
    fs.writeFileSync(@file, JSON.stringify(@data))


module.exports = Config
