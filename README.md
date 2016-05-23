fuzzy.io
========

Interface to the fuzzy.io API for machine intelligence.

License
-------

Copyright 2014-2016 fuzzy.io <node@fuzzy.io>

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

    var client = new FuzzyIOClient({key: apiKey});

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
--------------

This is the main class; it's what's returned from the require().

* **FuzzyIOClient(options)** Takes an `options` argument. This is an object with
  the following properties:

  * `key`: API key to use. You have to get an `apiKey` from
  https://fuzzy.io/ . Keep this secret, by the way.

  * `root` is the root of the API server. It has the correct default
  'https://api.fuzzy.io' but if you're doing some testing with a mock, it can be
  useful.

  * `queueLength` is the length of the request queue; requests are parallelized
  and a maximum of this number of requests will be done concurrently. This has
  a reasonable default of 32.

  * `maxWait` is the maximum time in seconds to wait for a response before
  returning an error. This has a reasonable default of 10 seconds.

  * `timeout` is how long persistent connections will stick around. The default
  is 0, meaning no persistent connections. If you are going to do a lot of
  requests, set this to something reasonable, like 1000 or 5000. Infinity means
  never disconnect (although the server will, eventually). Note that if you use
  persistent connections, you'll want to use `stop()` at the end of your program
  so the connections are cleaned up.

This is the main method you need to use:

* **evaluate(agentID, inputs, [meta], callback)** Does a single inference.
  `agentID` is on the main page for the agent on http://fuzzy.io/ .
  The `inputs` is an object, mapping input names
  to numeric values. `meta` is a string or boolean value; if provided and
  truthy, `output` will include a `meta` property with meta information, or
  a property with the same name as the string value, if you need to avoid using
  "meta" as a property.

  `callback` is a function with the signature `function(err, outputs)`, where
  `outputs` is an object mapping output names to numeric values. It may also
  have a `meta` or other specified property depending on the meta flag.

To train for better results, use the feedback method with your success metric.

* **feedback(evaluationID, metrics, callback)** Trains the agent based on the
  `evaluationID` is returned in the output for the `evaluate()` method (see above).
  The `success` is an object, mapping success metric names
  to numeric values. Defining the success metric is up to you,
  but closer to zero = better. `callback` is a function with the signature
  `function(err, metrics)`, where `metrics` is an object mapping output names to
  numeric values, which is just what you passed in plus some extra housekeeping
  data.

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

* **deleteAgent(agentID, callback)** Deletes an agent. This method will
  permanently delete an agent and all related data; use with caution. `callback`
  has the signature `function(err)` which returns an error if there was a
  problem.

* **evaluation(evaluationID, callback)** Gets the audit data for the evaluation.
  `evaluationID` is returned in the output for the `evaluate()` method (see above).
  `callback` is a function with the signature `function(err, audit)`,
  where `audit` is an object mapping audit data names to data. Important values
  here:

  * `input`: the input values that were passed in
  * `crisp`: the output values that were the results of the evaluation
  * `rules`: The index of the rules that fired

  Most of the rest is fuzzy logic stuff that you probably don't care about.

* **apiVersion(callback)** Get the version data from the server. This is a good
  "smoke test" method to see if the server is responding at all. `callback`
  has the signature `function(err, versionData)`, where `versionData` is an
  object with the following properties:

  * `name`: name of the API server. Usually `api`.
  * `version`: (Semver)[http://semver.org/] version for the API server software.
  * `controllerVersion`: Semver version for the fuzzy controller software.

* **stop(callback)** Clean up any persistent connections. You only need to call
  this if you provided a non-zero `timeout` to the constructor.
