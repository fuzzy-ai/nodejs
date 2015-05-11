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

web = require('fuzzy.io-web').web

JSON_TYPE = "application/json"
JSON_FULL_TYPE = "application/json; charset=utf8"

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

    handle = (verb) =>

      (rel, body, callback) =>

        if !callback
          callback = body
          body = undefined

        headers =
          authorization: "Bearer #{token}"

        if body
          payload = JSON.stringify(body)
          headers['Content-Type'] = JSON_FULL_TYPE
          headers['Content-Length'] = Buffer.byteLength payload
        else
          payload = null

        web verb, full(rel), headers, payload, (err, response, body) =>

          if err
            return callback err

          if response.statusCode >= 400 and response.statusCode < 500
            callback new ClientError(body.message or body, response.statusCode)
          if response.statusCode >= 500 and response.statusCode < 600
            callback new ServerError(body.message or body, response.statusCode)
          else if (!response.headers['content-type'])
            console.dir response.headers
            callback new ServerError("No Content-Type header set")
          else if (response.headers['content-type'].split(";")[0] != JSON_TYPE)
            callback new ServerError("Unexpected content type: #{response.headers['content-type']}")
          else
            try
              results = JSON.parse body
              callback null, results
            catch e
              callback e, null

    post = handle "POST"
    get = handle "GET"
    put = handle "PUT"

    @getAgents = (callback) =>
      get "/agent", callback

    @newAgent = (agent, callback) =>
      post "/agent", agent, callback

    @getAgent = (agentID, callback) =>
      get "/agent/#{agentID}", callback

    @evaluate = (agentID, inputs, callback) =>
      post "/agent/#{agentID}", inputs, callback

    @putAgent = (agentID, agent, callback) =>
      put "/agent/#{agentID}", agent, callback

module.exports = FuzzyIOClient
