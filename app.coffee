_ = require('underscore')
express = require("express")
cors = require("cors")
store = require './app/store'
app = express()
app.use express.logger()
app.use cors()
app.use express.bodyParser()

redis = require('redis-url').connect()

app.REDIS_LEADERBOARD_KEY = 'karma:leaderboard'

app.store = ->
  if not app.karmaStore?
    app.karmaStore = new store.Store app.REDIS_LEADERBOARD_KEY
  app.karmaStore

app.get "/", (request, response) ->
  response.send "Karma app."

app.get "/leaderboard", (request, response) ->
  app.store().leaderboard (entries) ->
    response.send entries

app.post "/upvote", (request, response) ->
  app.store().upvote request.body.user
  response.send 200

port = process.env.PORT or 5000
app.listen port, ->
  console.log "Listening on " + port

exports.app = app
