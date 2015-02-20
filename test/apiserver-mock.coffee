# apiserver-mock.coffee -- mock interface for testing the fuzzy.io class
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

http = require 'http'

_ = require 'lodash'

JSON_TYPE = "application/json; charset=utf-8"

class APIServerMock
  constructor: (userID, token) ->
    ids = []
    agent1 =
      id: "fakefakefakefake"
      userID: userID
      latestVersion: "ekafekafekafekaf"
      name: "temperature"
      inputs:
        temperature:
          cold: [50, 75]
          normal: [50, 75, 85, 100]
          hot: [85, 100]
      outputs:
        fanSpeed:
          slow: [50, 100]
          normal: [50, 100, 150, 200]
          fast: [150, 200]
      rules: [
        "IF temperature IS cold THEN fanSpeed IS slow"
        "IF temperature IS normal THEN fanSpeed IS normal"
        "IF temperature IS hot THEN fanSpeed IS fast"
      ]
      createdAt: "2014-12-17T18:18:14.850Z"
      updatedAt: "2014-12-17T18:18:14.850Z"
    agents = [
      agent1
    ]
    resp = (response, code, body) ->
      response.statusCode = code
      response.setHeader "Content-Type", JSON_TYPE
      response.end JSON.stringify(body)

    routes = [
      ["GET", "^/agent$", (request, response, match) ->
        resp response, 200, agents
      ],
      ["POST", "^/agent$", (request, response, match) ->
        if !_.isObject(request.body)
          resp response, 400, {status: "error", message: "Body not an object"}
          return
        if !_.has(request.body, "inputs")
          resp response, 400, {status: "error", message: "Body has no inputs"}
          return
        if !_.has(request.body, "outputs")
          resp response, 400, {status: "error", message: "Body has no outputs"}
          return
        if !_.has(request.body, "rules")
          resp response, 400, {status: "error", message: "Body has no rules"}
          return
        resp response, 200, agent1
      ],
      ["GET", "^/agent/(.*?)$", (request, response, match) ->
        resp response, 200, agent1
      ],
      ["POST", "^/agent/(.*?)$", (request, response, match) ->
        if !_.isObject(request.body)
          resp response, 400, {status: "error", message: "Body not an object"}
          return
        if _.keys(request.body).length == 0
          resp response, 400, {status: "error", message: "Body has no inputs"}
          return
        resp response, 200, {fanSpeed: 45.3}
      ],
      ["PUT", "^/agent/(.*?)$", (request, response, match) ->
        if !_.isObject(request.body)
          resp response, 400, {status: "error", message: "Body not an object"}
          return
        if !_.has(request.body, "inputs")
          resp response, 400, {status: "error", message: "Body has no inputs"}
          return
        if !_.has(request.body, "outputs")
          resp response, 400, {status: "error", message: "Body has no outputs"}
          return
        if !_.has(request.body, "rules")
          resp response, 400, {status: "error", message: "Body has no rules"}
          return
        resp response, 200, agent1
      ]
    ]

    server = http.createServer (request, response) ->
      body = ""
      respond = (code, body) ->
        response.statusCode = code
        if !response.headersSent
          response.setHeader "Content-Type", JSON_TYPE
        response.end(JSON.stringify(body))
      request.on "data", (chunk) ->
        body += chunk
      request.on "error", (err) ->
        respond 500, {status: "error", message: err.message}
      request.on "end", () ->
        auth = request.headers.authorization
        if !auth
          respond 403, {status: "error", message: "No Authorization header"}
          return
        am = auth.match(/^Bearer (.*?)$/)
        if not am
          respond 403, {status: "error", message: "No token in Authorization header"}
          return
        if am[1] != token
          respond 403, {status: "error", message: "Incorrect token in Authorization header (#{am[1]} != #{token})"}
          return
        if request.method != "GET"
          if body.length == 0
            respond 400, {status: "error", message: "No content in request"}
            return

          type = request.headers['content-type']
          if type.substr(0, "application/json".length) != "application/json"
            respond 400, {status: "error", message: "Not a JSON request; Content-Type = #{type}"}
            return

          try
            request.body = JSON.parse(body)
          catch err
            respond 400, {status: "error", message: err.message}
            return

        # Find a route
        for route in routes
          if request.method == route[0]
            match = request.url.match(route[1])
            if match
              return route[2](request, response, match)
        # If we get here, no route found
        respond 404, {status: "error", message: "Cannot #{request.method} #{request.url}"}

    @start = (callback) ->
      server.once 'error', (err) ->
        callback err
      server.once 'listening', () ->
        callback null
      server.listen 2342

    @stop = (callback) ->
      server.once 'close', () ->
        callback null
      server.once 'error', (err) ->
        callback err
      server.close()

module.exports = APIServerMock
