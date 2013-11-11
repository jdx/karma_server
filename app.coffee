_ = require('underscore')
express = require("express")
cors = require("cors")
app = express()
app.use express.logger()
app.use cors()
app.use express.bodyParser()

redis = require('redis-url').connect()

app.get "/", (request, response) ->
  response.send "Karma app."

app.get "/leaderboard", (request, response) ->
  redis.zrange "karma:leaderboard", 0, -1, "WITHSCORES", (code, leaderboard) ->
    list = []
    entries = leaderboard.reverse()
    for index in [0..entries.length-1] by 2
      list.push
        name: entries[index+1]
        karma: +entries[index]
    response.send list

app.post "/upvote", (request, response) ->
  redis.zincrby "karma:leaderboard", 1, request.body.user
  response.send 200

port = process.env.PORT or 5000
app.listen port, ->
  console.log "Listening on " + port
