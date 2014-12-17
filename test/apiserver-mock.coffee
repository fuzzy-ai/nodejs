# apiserver-mock.coffee
# Mock interface for testing the fuzzy.io class

http = require 'http'

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
      ["GET", "^/user/#{userID}/agents$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", "application/json"
        response.end JSON.stringify(agents)
      ],
      ["POST", "^/user/#{userID}/agents$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", "application/json"
        # XXX: use body
        response.end JSON.stringify(agent1)
      ],
      ["GET", "^/agent/(.*?)$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", "application/json"
        # XXX: use body
        response.end JSON.stringify(agent1)
      ],
      ["POST", "^/agent/(.*?)$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", "application/json"
        response.end JSON.stringify({fanSpeed: 45.3})
      ],
      ["PUT", "^/agent/(.*?)$", (request, response, match) ->
        response.statusCode = 200
        response.setHeader "Content-Type", "application/json"
        response.end JSON.stringify(agent1)
      ]
    ]

    server = http.createServer (request, response) ->
      # Check authentication
      auth = request.headers.authorization
      am = auth.match(/^Bearer (.*?)$/)
      if not am or am[1] != token
        response.statusCode = 404
        response.end("Cannot #{request.method} #{request.url}")
        return
      # Find a route
      for route in routes
        if request.method == route[0]
          match = request.url.match(route[1])
          if match
            return route[2](request, response, match)
      # If we get here, no route found
      response.statusCode = 404
      response.end("Cannot #{request.method} #{request.url}")

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
