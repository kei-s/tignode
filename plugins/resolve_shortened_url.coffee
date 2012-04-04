url = require 'url'
http = require 'http'
_ = require 'underscore'
{EventEmitter} = require 'events'
path = require 'path'
expandUrl  = require('./expand_url').expandUrl

expandUrl.resolvers.push({
  resolve: (response, data) ->
    if /http:\/\/(?:tinyurl\.com|bit\.ly|goo\.gl|htn\.to|j.mp|amzn.to)\/[A-Za-z0-9_/.;%&\-]+/.test (source = (data.expanded_url || data.url))
      console.log data
      req = http.request _.extend(url.parse(source), {method: 'HEAD'}), (res) =>
        resolved_url = res.headers.location || source
        console.log resolved_url
        response.message = response.message.replace(data.expanded_url, resolved_url)
      req.end()
})

module.exports.expandUrl = expandUrl
