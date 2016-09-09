# fuzzy.ai.coffee -- Interface to fuzzy.ai API
#
# Copyright 2014-2016 Fuzzy.ai <node@fuzzy.ai>
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

_ = require 'lodash'

MicroserviceClient = require 'fuzzy.ai-microservice-client'

defaults =
  root: "https://api.fuzzy.ai"
  queueLength: 32
  maxWait: 10
  timeout: 0

class FuzzyAIClient extends MicroserviceClient

  @start: ->
    undefined

  @stop: ->
    undefined

  constructor: (args...) ->

    if args.length < 1
      throw new Exception("At least one argument required")

    if _.isObject args[0]
      props = _.defaults args[0], defaults
    else if _.isString args[0]
      props = {}
      _.assign props, defaults
      props.key = args[0]
      if args.length > 1
        props.root = args[1]
      if args.length > 2
        props.queueLength = args[2]
      if args.length > 3
        props.maxWait = args[3]

    super props

  getAgents: (callback) ->
    @get "/agent", callback

  newAgent: (agent, callback) ->
    @post "/agent", agent, callback

  getAgent: (agentID, callback) ->
    @get "/agent/#{agentID}", callback

  evaluate: (agentID, inputs, meta, callback) ->
    if !callback?
      callback = meta
      meta = false
    if _.isString meta
      url = "/agent/#{agentID}?meta=#{meta}"
    else if meta
      url = "/agent/#{agentID}?meta=true"
    else
      url = "/agent/#{agentID}"
    @post url, inputs, (err, results) ->
      if err
        callback err
      else
        # This is the old way we used to pass this; leaving it here
        # since it's mostly harmless
        results._evaluation_id = null
        callback null, results

  evaluation: (evaluationID, callback) ->
    @get "/evaluation/#{evaluationID}", callback

  feedback: (evaluationID, feedback, callback) ->
    @post "/evaluation/#{evaluationID}/feedback", feedback, callback

  putAgent: (agentID, agent, callback) ->
    @put "/agent/#{agentID}", agent, callback

  deleteAgent: (agentID, callback) ->
    @delete "/agent/#{agentID}", (err, results) ->
      callback err

  apiVersion: (callback) ->
    @get "/version", callback

  getAgentVersion: (id, callback) ->
    @get "/version/#{id}", callback

module.exports = FuzzyAIClient
