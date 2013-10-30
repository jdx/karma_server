express = require("express")
app = express()
app.use express.logger()

app.all '*', (req, res, next) ->
  res.header("Access-Control-Allow-Origin", "*")
  res.header("Access-Control-Allow-Headers", "X-Requested-With")
  if req.method == 'OPTIONS'
    res.send(200)
  else
    next()

app.get "/", (request, response) ->
  response.send "Karma app."

app.get "/top", (request, response) ->
  response.send [
    { name: 'dickeyxxx', karma: 50 },
    { name: 'dickeyxxx', karma: 50 },
    { name: 'dickeyxxx', karma: 50 },
    { name: 'dickeyxxx', karma: 50 }
  ]

port = process.env.PORT or 5000
app.listen port, ->
  console.log "Listening on " + port