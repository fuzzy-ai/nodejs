# fuzzy.io.coffee -- Interface to fuzzy.io API
#
# Copyright 2014 fuzzy.io <evan@fuzzy.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

request = require 'request'

class ClientError extends Error
  constructor: (@message, @statusCode) ->
    @name = "ClientError"
    Error.captureStackTrace(this, ClientError)

class ServerError extends Error
  constructor: (@message, @statusCode) ->
    @name = "ServerError"
    Error.captureStackTrace(this, ServerError)

class FuzzyIOClient
  constructor: (token, apiServer = "https://api.fuzzy.io") ->

    full = (rel) =>
      apiServer + rel

    post = (rel, json, callback) =>

      options =
        url: full rel
        json: json
        headers:
          authorization: "Bearer #{token}"

      request.post options, (err, response, body) =>

        if err
          return callback err

        if response.statusCode >= 400 and response.statusCode < 500
          callback new ClientError(body.message or body, response.statusCode)
        if response.statusCode >= 500 and response.statusCode < 600
          callback new ServerError(body.message or body, response.statusCode)
        else
          callback null, body

    get = (rel, callback) =>

      options =
        url: full rel
        json: true
        headers:
          authorization: "Bearer #{token}"

      request.get options, (err, response, body) =>

        if err
          return callback err

        if response.statusCode >= 400 and response.statusCode < 500
          callback new ClientError(body.message or body, response.statusCode)
        if response.statusCode >= 500 and response.statusCode < 600
          callback new ServerError(body.message or body, response.statusCode)
        else
          callback null, body

    put = (rel, json, callback) =>

      options =
        method: "PUT"
        url: full rel
        json: json
        headers:
          authorization: "Bearer #{token}"

      request options, (err, response, body) =>
        if err
          callback err
        else if response.statusCode >= 400 and response.statusCode < 500
          callback new ClientError(body.message, response.statusCode)
        else if response.statusCode >= 500 and response.statusCode < 600
          callback new ServerError(body.message, response.statusCode)
        else
          callback null, body

    @getAgents = (userID, callback) =>
      get "/user/#{userID}/agent", callback

    @newAgent = (userID, agent, callback) =>
      post "/user/#{userID}/agent", agent, callback

    @getAgent = (agentID, callback) =>
      get "/agent/#{agentID}", callback

    @evaluate = (agentID, inputs, callback) =>
      post "/agent/#{agentID}", inputs, callback

    @putAgent = (agentID, agent, callback) =>
      put "/agent/#{agentID}", agent, callback

module.exports = FuzzyIOClient
