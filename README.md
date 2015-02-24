fuzzy.io
========

Interface to the fuzzy.io API for machine intelligence.

License
-------

Copyright 2014 fuzzy.io <node@fuzzy.io>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Overview
--------

    var FuzzyIOClient = require('fuzzy.io');

    var apiKey = 'API key from fuzzy.io';

    var client = new FuzzyIOClient(apiKey);

    var agentID = 'ID from fuzzy.io';

    var inputs = {temperature: 87};

    client.evaluate(agentID, inputs, function(err, outputs) {
      if (err) {
        console.error(err);
      } else {
        console.log("Fan speed is " + outputs.fanSpeed);
      }
    });

FuzzyIOClient
-------------

This is the main class; it's what's returned from the require().

* **FuzzyIOClient(apiKey, apiRoot)** You have to get an `apiKey` from
  http://fuzzy.io/ . Keep this secret, by the way. `serverRoot` is the root of
  the API server. It has the correct default 'https://api.fuzzy.io' but if
  you're doing some testing with a mock, it can be useful.

This is the main method you need to use:

* **evaluate(agentID, inputs, callback)** Does a single inference.
  `agentID` is on the main page for the agent on http://fuzzy.io/ .
  The `inputs` is an object, mapping input names
  to numeric values. `callback` is a function with the signature
  `function(err, outputs)`, where `outputs` is an object mapping output names to
  numeric values.

These might be useful but you normally don't need to mess with them.

* **getAgents(callback)** `userID` is the user ID, *not* the API key.
  `callback` is a function with the signature `function(err, agents)`, where
  `agents` is an array of objects with `id` and `name` properties, one for
  each agent the user has.

* **newAgent(agent, callback)** `userID` is the user ID. `agent` is an
  agent object with at least properties `inputs`, `outputs`, `rules`. `callback`
  is a function with the signature `function(err, agent)` which returns the
  fully-realized agent with all its properties like timestamps and IDs.

* **getAgent(agentID, callback)** Gets a single agent by ID. `callback` is a
  function with the signature `function(err, agent)`.

* **putAgent(agentID, agent, callback)** Updates an agent. `callback` has the
  signature `function(err, agent)` which will return the updated version.
