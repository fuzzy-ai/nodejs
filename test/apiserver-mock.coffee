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
    routes = [
      ["GET", "^/agent$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", JSON_TYPE
        response.end JSON.stringify(agents)
      ],
      ["POST", "^/agent$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", JSON_TYPE
        # XXX: use body
        response.end JSON.stringify(agent1)
      ],
      ["GET", "^/agent/(.*?)$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", JSON_TYPE
        # XXX: use body
        response.end JSON.stringify(agent1)
      ],
      ["POST", "^/agent/(.*?)$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", JSON_TYPE
        response.end JSON.stringify({fanSpeed: 45.3})
      ],
      ["PUT", "^/agent/(.*?)$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", JSON_TYPE
        response.end JSON.stringify(agent1)
      ]
    ]

    server = http.createServer (request, response) ->
      # Check authentication
      auth = request.headers.authorization
      am = auth.match(/^Bearer (.*?)$/)
      if not am or am[1] != token
        response.statusCode = 400
        response.setHeader "Content-Type", JSON_TYPE
        response.end(JSON.stringify({status: "error", message: "Cannot #{request.method} #{request.url}"}))
        return
      # Find a route
      for route in routes
        if request.method == route[0]
          match = request.url.match(route[1])
          if match
            return route[2](request, response, match)
      # If we get here, no route found
      response.statusCode = 404
      response.setHeader "Content-Type", JSON_TYPE
      response.end(JSON.stringify({status: "error", message: "Cannot #{request.method} #{request.url}"}))

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
