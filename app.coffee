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

app.get "/users", (request, response) ->
  response.send ["@dickeyxxx", "@michaelavila", "@laser"]

app.get "/leaderboard", (request, response) ->
  redis.zrange "karma:leaderboard", 0, -1, "WITHSCORES", (code, leaderboard) ->
    list = []
    counter = 0
    _.each leaderboard, (element) ->
      if counter % 2 == 0
        list.push { name: element }
      else
        list[list.length - 1]["karma"] = element
      counter++
    response.send list.reverse()

app.post "/upvote", (request, response) ->
  redis.zincrby "karma:leaderboard", 1, request.body.user
  response.send 200

port = process.env.PORT or 5000
app.listen port, ->
  console.log "Listening on " + port
