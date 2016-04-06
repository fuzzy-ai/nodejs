# module-test.coffee -- test core functionality of fuzzy.io module
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

process.on 'uncaughtException', (err) ->
  console.error err

vows = require 'vows'
assert = require 'assert'

USERID = 'ersatz1234'
TOKEN = 'madeup5678'
AGENTID = 'spurious9101'
AGENTID2 = 'notreal1121'

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
        callback = @callback
        mock.stop (err) =>
          callback null
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
        'and we start the module':
          topic: (FuzzyIOClient) ->
            callback = @callback
            try
              FuzzyIOClient.start()
              callback null, FuzzyIOClient
            catch err
              callback err
            undefined
          'it works': (err, FuzzyIOClient) ->
            assert.ifError err
          'teardown': (FuzzyIOClient) ->
            FuzzyIOClient.stop()
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
                assert.isFunction client.deleteAgent, "deleteAgent"
                assert.isFunction client.apiVersion, "apiVersion"
              'and we check the API version':
                topic: (client) ->
                  client.apiVersion @callback
                  undefined
                'it works': (err, versionData) ->
                  assert.ifError err
                'it has the API version number': (err, versionData) ->
                  assert.ifError err
                  assert.isObject versionData
                  assert.isString versionData.version
                'it has the implementation name': (err, versionData) ->
                  assert.ifError err
                  assert.isObject versionData
                  assert.isString versionData.name
                'it has the controller version number': (err, versionData) ->
                  assert.ifError err
                  assert.isObject versionData
                  assert.isString versionData.controllerVersion
              'and we get the user agents':
                topic: (client) ->
                  client.getAgents @callback
                  undefined
                'it works': (err, agents) ->
                  assert.ifError err
                  assert.isArray agents
                  for agent in agents
                    assert.isObject agent
                    assert.isString agent.id
                    assert.isString agent.name
              'and we add a user agent':
                topic: (client) ->
                  client.newAgent AGENT, @callback
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
              'and we delete an agent':
                topic: (client) ->
                  client.deleteAgent AGENTID2, @callback
                  undefined
                'it works': (err) ->
                  assert.ifError err
              'and we evaluate':
                topic: (client) ->
                  client.evaluate AGENTID, {input1: 69}, @callback
                  undefined
                'it works': (err, outputs) ->
                  assert.ifError err
                  assert.isObject outputs
              'and we evaluate with the meta flag':
                topic: (client) ->
                  client.evaluate AGENTID, {input1: 69}, true, @callback
                  undefined
                'it works': (err, outputs) ->
                  assert.ifError err
                  assert.isObject outputs
                  assert.isObject outputs.meta
                  assert.isString outputs.meta.reqID
                'and we get the audit information':
                  topic: (outputs, client) ->
                    client.evaluation outputs.meta.reqID, @callback
                    undefined
                  'it works': (err, evaluation) ->
                    assert.ifError err
                    assert.isObject evaluation
                'and we provide feedback':
                  topic: (outputs, client) ->
                    client.feedback outputs.meta.reqID, {size: 13}, @callback
                    undefined
                  'it works': (err, feedback) ->
                    assert.ifError err
                    assert.isObject feedback
              'and we evaluate with the meta flag set to a string value':
                topic: (client) ->
                  client.evaluate AGENTID, {input1: 69}, 'audit', @callback
                  undefined
                'it works': (err, outputs) ->
                  assert.ifError err
                  assert.isObject outputs
                  assert.isObject outputs.audit
                  assert.isString outputs.audit.reqID
                'and we get the audit information':
                  topic: (outputs, client) ->
                    client.evaluation outputs.audit.reqID, @callback
                    undefined
                  'it works': (err, evaluation) ->
                    assert.ifError err
                    assert.isObject evaluation
                'and we provide feedback':
                  topic: (outputs, client) ->
                    client.feedback outputs.audit.reqID, {size: 13}, @callback
                    undefined
                  'it works': (err, feedback) ->
                    assert.ifError err
                    assert.isObject feedback

  .export(module)
