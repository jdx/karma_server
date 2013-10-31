express = require("express")
cors = require("cors")
app = express()
app.use express.logger()
app.use cors()
app.use express.bodyParser()

app.get "/", (request, response) ->
  response.send "Karma app."

app.get "/users", (request, response) ->
  response.send ["@dickeyxxx", "@michaelavila", "@laser"]

app.get "/leaderboard", (request, response) ->
  response.send [
    { name: '@dickeyxxx', karma: 50 },
    { name: '@dickeyxxx', karma: 50 },
    { name: '@dickeyxxx', karma: 50 },
    { name: '@dickeyxxx', karma: 50 }
  ]

app.post "/upvote", (request, response) ->
  response.send request.body.user

port = process.env.PORT or 5000
app.listen port, ->
  console.log "Listening on " + port
