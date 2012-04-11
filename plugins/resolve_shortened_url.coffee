url = require 'url'
http = require 'http'
_ = require 'underscore'
async = require 'async'
{EventEmitter} = require 'events'

class ResolveShortenedUrl extends EventEmitter
  constructor: ->
    ['tweet', 'retweet'].forEach (event) =>
      this.on event, (process, user, subject, data) =>
        functions = _.map(data.entities.urls, (url_data) =>
          (callback) => this.resolve(callback, url_data)
        )
        async.parallel functions, (err, results) ->
          results.forEach (result) ->
            if result
              process.message = process.message.replace(result.source, result.resolved)
          process.done()

  resolve: (callback, url_data) ->
    if /http:\/\/(?:tinyurl\.com|bit\.ly|goo\.gl|htn\.to|j.mp|amzn.to)\/[A-Za-z0-9_/.;%&\-]+/.test (source = (url_data.expanded_url || url_data.url))
      req = http.request _.extend(url.parse(source), {method: 'HEAD'}), (res) =>
        if res.headers.location
          callback(null, {source: source, resolved: res.headers.location})
        else
          callback()
      req.end()
    else
      callback()

module.exports.resolveShortenedUrl = new ResolveShortenedUrl
