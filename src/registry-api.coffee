q = require 'q'
_ = require 'lodash'
request = require 'request'

# Private: Wraps request styled callback in a deferred-calling function
wrapPromise = (resolve, reject) ->
  (error, response, body) ->
    if error
      reject error
      return
    if "#{response.statusCode}".substring(0, 1) == '4'
      reject response.statusCode
      return
    resolve body

# Public: Docker Registry API Abstraction
module.exports =
class RegistryApi

  constructor: (@endpoint = 'https://registry.hub.docker.com') ->

  getLatestTagForImage: (image) ->
    q.promise (resolve, reject) =>
      request.get "#{@endpoint}/v1/repositories/#{image}/tags", json: true, wrapPromise resolve, reject
    .then (layers) ->
      latest = _.find layers, name: 'latest'
      latestTag = _.find layers, (layer) ->
        true if layer.layer is latest.layer and layer.name isnt 'latest'

      return latestTag
    .catch (error) ->
      if error is 404
        throw new Error "Unknown image \"#{image}\". The image must exist in the registry."
      else
        throw error
