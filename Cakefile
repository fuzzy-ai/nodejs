fs = require 'fs'

{print} = require 'sys'
{spawn} = require 'child_process'

glob = require 'glob'

cmd = (str, callback) ->
  parts = str.split(' ')
  main = parts[0]
  rest = parts.slice(1)
  proc = spawn main, rest
  proc.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  proc.stdout.on 'data', (data) ->
    print data.toString()
  proc.on 'exit', (code) ->
    callback?() if code is 0

build = (callback) ->
  cmd 'coffee -c -o lib src', ->
    cmd 'coffee -c test'

task 'build', 'Build lib/ from src/', ->
  build()

task 'watch', 'Watch src/ for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'clean', 'Clean up extra files', ->
  patterns = ["lib/*.js", "test/*.js", "*~", "lib/*~", "src/*~", "test/*~"]
  for pattern in patterns
    glob pattern, (err, files) ->
      for file in files
        fs.unlinkSync file

task 'test', 'Run tests', ->
  invoke 'clean'
  build ->
    cmd 'vows tests/*-test.js'
