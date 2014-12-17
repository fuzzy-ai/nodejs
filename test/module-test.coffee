# apiserver-mock.coffee
# Mock interface for testing the fuzzy.io class

vows = require 'vows'
assert = require 'assert'

USERID = 'ersatz1234'
TOKEN = 'madeup5678'
AGENTID = 'spurious9101'
AGENT =
  inputs:
    input1:
      veryLow: [0, 20]
      low: [5, 25, 45]
      medium: [30, 50, 70]
      high: [55, 75, 95]
      veryHigh: [80, 100]
  outputs:
    output1:
      veryLow: [0, 20]
      low: [5, 25, 45]
      medium: [30, 50, 70]
      high: [55, 75, 95]
      veryHigh: [80, 100]
  rules: [
    "IF input1 IS veryLow THEN output1 IS veryLow"
    "IF input1 IS low THEN output1 IS low"
    "IF input1 IS medium THEN output1 IS medium"
    "IF input1 IS high THEN output1 IS high"
    "IF input1 IS veryHigh THEN output1 IS veryHigh"
  ]

vows
  .describe('Basic fuzzy.io test')
  .addBatch
    'When we start the mock server':
      topic: ->
        APIServerMock = require './apiserver-mock'
        mock = new APIServerMock(USERID, TOKEN)
        mock.start (err) =>
          @callback err, mock
        undefined
      'it works': (err, mock) ->
        assert.ifError err
        assert.isObject mock
      'teardown': (mock) ->
        mock.stop (err) =>
          @callback err
        undefined
      'and we load the fuzzy.io library':
        topic: ->
          try
            mod = require '../lib/fuzzy.io'
            @callback null, mod
          catch err
            @callback err, null
          undefined
        'it works': (err, mod) ->
          assert.ifError err
          assert.isFunction mod
        'and we create a client with the mock address':
          topic: (FuzzyIOClient) ->
            try
              client = new FuzzyIOClient(TOKEN, "http://localhost:2342")
              @callback null, client
            catch err
              @callback err, null
            undefined
          'it works': (err, client) ->
            assert.ifError err
            assert.isObject client
          'and we examine the client':
            topic: (client) ->
              client
            'it has the right public methods': (client) ->
              assert.isFunction client.getAgents, "getAgents"
              assert.isFunction client.newAgent, "newAgent"
              assert.isFunction client.getAgent, "getAgent"
              assert.isFunction client.evaluate, "evaluate"
              assert.isFunction client.putAgent, "putAgent"
            'and we get the user agents':
              topic: (client) ->
                client.getAgents USERID, @callback
                undefined
              'it works': (err, agents) ->
                assert.ifError err
                assert.isArray agents
                for agent in agents
                  assert.isObject agent
            'and we add a user agent':
              topic: (client) ->
                client.newAgent USERID, AGENT, @callback
                undefined
              'it works': (err, agent) ->
                assert.ifError err
                assert.isObject agent
            'and we get an agent':
              topic: (client) ->
                client.getAgent AGENTID, @callback
                undefined
              'it works': (err, agent) ->
                assert.ifError err
                assert.isObject agent
            'and we update an agent':
              topic: (client) ->
                client.putAgent AGENTID, AGENT, @callback
                undefined
              'it works': (err, agent) ->
                assert.ifError err
                assert.isObject agent


  .export(module)
