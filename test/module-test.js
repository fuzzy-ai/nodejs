// module-test.coffee -- test core functionality of fuzzy.ai module
//
// Copyright 2014-2016 Fuzzy.ai <node@fuzzy.ai>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

process.on('uncaughtException', err => console.error(err))

const vows = require('vows')
const assert = require('assert')

const USERID = 'ersatz1234'
const TOKEN = 'madeup5678'
const AGENTID = 'spurious9101'
const AGENTID2 = 'notreal1121'
const VERSIONID = 'ekafekafekafekaf'

const AGENT = {
  inputs: {
    input1: {
      veryLow: [0, 20],
      low: [5, 25, 45],
      medium: [30, 50, 70],
      high: [55, 75, 95],
      veryHigh: [80, 100]
    }
  },
  outputs: {
    output1: {
      veryLow: [0, 20],
      low: [5, 25, 45],
      medium: [30, 50, 70],
      high: [55, 75, 95],
      veryHigh: [80, 100]
    }
  },
  rules: [
    'IF input1 IS veryLow THEN output1 IS veryLow',
    'IF input1 IS low THEN output1 IS low',
    'IF input1 IS medium THEN output1 IS medium',
    'IF input1 IS high THEN output1 IS high',
    'IF input1 IS veryHigh THEN output1 IS veryHigh'
  ]
}

vows
  .describe('Basic fuzzy.ai test')
  .addBatch({
    'When we start the mock server': {
      topic () {
        const APIServerMock = require('./apiserver-mock')
        const mock = new APIServerMock(USERID, TOKEN)
        mock.start(err => {
          return this.callback(err, mock)
        })
        return undefined
      },
      'it works' (err, mock) {
        assert.ifError(err)
        return assert.isObject(mock)
      },
      'teardown' (mock) {
        const { callback } = this
        mock.stop(err => callback(null))
        return undefined
      },
      'and we load the fuzzy.ai library': {
        topic () {
          try {
            const mod = require('../lib/fuzzy.ai')
            this.callback(null, mod)
          } catch (err) {
            this.callback(err, null)
          }
          return undefined
        },
        'it works' (err, mod) {
          assert.ifError(err)
          return assert.isFunction(mod)
        },
        'and we start the module': {
          topic (FuzzyAIClient) {
            const { callback } = this
            try {
              FuzzyAIClient.start()
              callback(null, FuzzyAIClient)
            } catch (err) {
              callback(err)
            }
            return undefined
          },
          'it works' (err, FuzzyAIClient) {
            return assert.ifError(err)
          },
          'teardown' (FuzzyAIClient) {
            return FuzzyAIClient.stop()
          },
          'and we create a client with the mock address': {
            topic (FuzzyAIClient) {
              try {
                const client = new FuzzyAIClient(TOKEN, 'http://localhost:2342')
                this.callback(null, client)
              } catch (err) {
                this.callback(err, null)
              }
              return undefined
            },
            'it works' (err, client) {
              assert.ifError(err)
              return assert.isObject(client)
            },
            teardown (client) {
              const { callback } = this
              client.stop(err => callback(null))
              return undefined
            },
            'and we examine the client': {
              topic (client) {
                return client
              },
              'it has the right public methods' (client) {
                assert.isFunction(client.getAgents, 'getAgents')
                assert.isFunction(client.newAgent, 'newAgent')
                assert.isFunction(client.getAgent, 'getAgent')
                assert.isFunction(client.evaluate, 'evaluate')
                assert.isFunction(client.putAgent, 'putAgent')
                assert.isFunction(client.deleteAgent, 'deleteAgent')
                assert.isFunction(client.apiVersion, 'apiVersion')
                return assert.isFunction(client.getAgentVersion, 'getAgentVersion')
              },
              'it has the inherited EventEmitter methods' (client) {
                // There are others; these are commonly-used ones
                assert.isFunction(client.on, 'on')
                assert.isFunction(client.once, 'once')
                return assert.isFunction(client.removeListener, 'removeListener')
              },
              'and we check the API version': {
                topic (client) {
                  client.apiVersion(this.callback)
                  return undefined
                },
                'it works' (err, versionData) {
                  return assert.ifError(err)
                },
                'it has the API version number' (err, versionData) {
                  assert.ifError(err)
                  assert.isObject(versionData)
                  return assert.isString(versionData.version)
                },
                'it has the implementation name' (err, versionData) {
                  assert.ifError(err)
                  assert.isObject(versionData)
                  return assert.isString(versionData.name)
                },
                'it has the controller version number' (err, versionData) {
                  assert.ifError(err)
                  assert.isObject(versionData)
                  return assert.isString(versionData.controllerVersion)
                }
              },
              'and we get the user agents': {
                topic (client) {
                  client.getAgents(this.callback)
                  return undefined
                },
                'it works' (err, agents) {
                  assert.ifError(err)
                  assert.isArray(agents)
                  return (() => {
                    const result = []
                    for (const agent of Array.from(agents)) {
                      assert.isObject(agent)
                      assert.isString(agent.id)
                      result.push(assert.isString(agent.name))
                    }
                    return result
                  })()
                }
              },
              'and we add a user agent': {
                topic (client) {
                  client.newAgent(AGENT, this.callback)
                  return undefined
                },
                'it works' (err, agent) {
                  assert.ifError(err)
                  return assert.isObject(agent)
                }
              },
              'and we get an agent': {
                topic (client) {
                  client.getAgent(AGENTID, this.callback)
                  return undefined
                },
                'it works' (err, agent) {
                  assert.ifError(err)
                  return assert.isObject(agent)
                }
              },
              'and we update an agent': {
                topic (client) {
                  client.putAgent(AGENTID, AGENT, this.callback)
                  return undefined
                },
                'it works' (err, agent) {
                  assert.ifError(err)
                  return assert.isObject(agent)
                }
              },
              'and we delete an agent': {
                topic (client) {
                  client.deleteAgent(AGENTID2, this.callback)
                  return undefined
                },
                'it works' (err) {
                  return assert.ifError(err)
                }
              },
              'and we evaluate': {
                topic (client) {
                  client.evaluate(AGENTID, {input1: 69}, this.callback)
                  return undefined
                },
                'it works' (err, outputs) {
                  assert.ifError(err)
                  return assert.isObject(outputs)
                }
              },
              'and we evaluate with the meta flag': {
                topic (client) {
                  client.evaluate(AGENTID, {input1: 69}, true, this.callback)
                  return undefined
                },
                'it works' (err, outputs) {
                  assert.ifError(err)
                  assert.isObject(outputs)
                  assert.isObject(outputs.meta)
                  return assert.isString(outputs.meta.reqID)
                },
                'and we get the audit information': {
                  topic (outputs, client) {
                    client.evaluation(outputs.meta.reqID, this.callback)
                    return undefined
                  },
                  'it works' (err, evaluation) {
                    assert.ifError(err)
                    return assert.isObject(evaluation)
                  }
                },
                'and we provide feedback': {
                  topic (outputs, client) {
                    client.feedback(outputs.meta.reqID, {size: 13}, this.callback)
                    return undefined
                  },
                  'it works' (err, feedback) {
                    assert.ifError(err)
                    return assert.isObject(feedback)
                  }
                }
              },
              'and we evaluate with the meta flag set to a string value': {
                topic (client) {
                  client.evaluate(AGENTID, {input1: 69}, 'audit', this.callback)
                  return undefined
                },
                'it works' (err, outputs) {
                  assert.ifError(err)
                  assert.isObject(outputs)
                  assert.isObject(outputs.audit)
                  return assert.isString(outputs.audit.reqID)
                },
                'and we get the audit information': {
                  topic (outputs, client) {
                    client.evaluation(outputs.audit.reqID, this.callback)
                    return undefined
                  },
                  'it works' (err, evaluation) {
                    assert.ifError(err)
                    return assert.isObject(evaluation)
                  }
                },
                'and we provide feedback': {
                  topic (outputs, client) {
                    client.feedback(outputs.audit.reqID, {size: 13}, this.callback)
                    return undefined
                  },
                  'it works' (err, feedback) {
                    assert.ifError(err)
                    return assert.isObject(feedback)
                  }
                }
              },
              'and we get an agent version': {
                topic (client) {
                  client.getAgentVersion(VERSIONID, this.callback)
                  return undefined
                },
                'it works' (err, version) {
                  return assert.ifError(err)
                },
                'it looks correct' (err, data) {
                  assert.ifError(err)
                  assert.isObject(data)
                  assert.isObject(data.inputs)
                  assert.isObject(data.outputs)
                  for (const rule of Array.from(data.rules)) {
                    assert.isString(rule)
                  }
                  assert.isArray(data.parsed_rules)
                  for (const parsed_rule of Array.from(data.parsed_rules)) {
                    assert.isObject(parsed_rule)
                  }
                  assert.isString(data.id)
                  assert.isString(data.userID)
                  assert.isString(data.versionOf)
                  return assert.isString(data.createdAt)
                }
              }
            }
          },

          'and we create a client with a non-zero timeout': {
            topic (FuzzyAIClient) {
              try {
                const client = new FuzzyAIClient({
                  key: TOKEN,
                  root: 'http://localhost:2342',
                  timeout: 5000
                })
                this.callback(null, client)
              } catch (err) {
                this.callback(err, null)
              }
              return undefined
            },
            'it works' (err, client) {
              assert.ifError(err)
              return assert.isObject(client)
            },
            teardown (client) {
              const { callback } = this
              client.stop(err => callback(null))
              return undefined
            },
            'and we get an agent': {
              topic (client) {
                client.getAgent(AGENTID, this.callback)
                return undefined
              },
              'it works' (err, agent) {
                assert.ifError(err)
                return assert.isObject(agent)
              }
            }
          }
        }
      }
    }}).export(module)
