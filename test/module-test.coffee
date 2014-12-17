# apiserver-mock.coffee
# Mock interface for testing the fuzzy.io class

vows = require 'vows'
assert = require 'assert'

USERID = 'ersatz1234'
TOKEN = 'madeup5678'

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
  .export(module)
