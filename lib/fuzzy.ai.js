// fuzzy.ai.coffee -- Interface to fuzzy.ai API
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

const _ = require('lodash');

const MicroserviceClient = require('@fuzzy-ai/microservice-client');

const defaults = {
  root: "https://api.fuzzy.ai",
  queueLength: 32,
  maxWait: 10,
  timeout: 0
};

class FuzzyAIClient extends MicroserviceClient {

  static start() {
    return undefined;
  }

  static stop() {
    return undefined;
  }

  constructor(...args) {

    let props;
    if (args.length < 1) {
      throw new Exception("At least one argument required");
    }

    if (_.isObject(args[0])) {
      props = _.defaults(args[0], defaults);
    } else if (_.isString(args[0])) {
      props = {};
      _.assign(props, defaults);
      props.key = args[0];
      if (args.length > 1) {
        props.root = args[1];
      }
      if (args.length > 2) {
        props.queueLength = args[2];
      }
      if (args.length > 3) {
        props.maxWait = args[3];
      }
    }

    super(props);
  }

  getAgents(callback) {
    return this.get("/agent", callback);
  }

  newAgent(agent, callback) {
    return this.post("/agent", agent, callback);
  }

  getAgent(agentID, callback) {
    return this.get(`/agent/${agentID}`, callback);
  }

  evaluate(agentID, inputs, meta, callback) {
    let url;
    if ((callback == null)) {
      callback = meta;
      meta = false;
    }
    if (_.isString(meta)) {
      url = `/agent/${agentID}?meta=${meta}`;
    } else if (meta) {
      url = `/agent/${agentID}?meta=true`;
    } else {
      url = `/agent/${agentID}`;
    }
    return this.post(url, inputs, function(err, results) {
      if (err) {
        return callback(err);
      } else {
        // This is the old way we used to pass this; leaving it here
        // since it's mostly harmless
        results._evaluation_id = null;
        return callback(null, results);
      }
    });
  }

  evaluation(evaluationID, callback) {
    return this.get(`/evaluation/${evaluationID}`, callback);
  }

  feedback(evaluationID, feedback, callback) {
    return this.post(`/evaluation/${evaluationID}/feedback`, feedback, callback);
  }

  putAgent(agentID, agent, callback) {
    return this.put(`/agent/${agentID}`, agent, callback);
  }

  deleteAgent(agentID, callback) {
    return this.delete(`/agent/${agentID}`, (err, results) => callback(err));
  }

  apiVersion(callback) {
    return this.get("/version", callback);
  }

  getAgentVersion(id, callback) {
    return this.get(`/version/${id}`, callback);
  }
}

module.exports = FuzzyAIClient;
