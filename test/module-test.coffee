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
  .export(module)
