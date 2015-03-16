# web.js
#
# Wrap http/https requests in a callback interface
#
# Copyright 2012, E14N https://e14n.com/
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

urlparse = require('url').parse
http = require('http')
https = require('https')

web = (verb, url, headers, reqBody, callback) ->

    # Optional body

    if !callback
      callback = reqBody
      body = null

    parts = urlparse url

    if parts.protocol == 'http:'
      mod = http
    else if parts.protocol == 'https:'
      mod = https
    else
      callback new Error("Unsupported protocol: #{parts.protocol}")

    options =
      host: parts.hostname
      port: parts.port
      path: parts.path
      method: verb.toUpperCase()
      headers: headers
      agent: false

    req = mod.request options, (res) ->
      resBody = ''
      res.setEncoding 'utf8'
      res.on 'data', (chunk) ->
        resBody = resBody + chunk
      res.on 'error', (err) ->
        console.log "Results error"
        console.error err
        callback err, null
      res.on 'end', ->
        callback null, res, resBody

    req.on 'error', (err) ->
      console.log "Request error"
      console.error err
      callback err, null

    if reqBody
      req.write reqBody

    req.end()

get = (url, headers, callback) ->
  web "GET", url, headers, callback

post = (url, headers, body, callback) ->
  web "POST", url, headers, body, callback

head = (url, headers, callback) ->
  web "HEAD", url, headers, callback

put = (url, headers, body, callback) ->
  web "PUT", url, headers, body, callback

del = (url, headers, callback) ->
  web "DELETE", url, headers, callback

module.exports =
  web: web
  get: get
  post: post
  head: head
  put: put
  del: del
