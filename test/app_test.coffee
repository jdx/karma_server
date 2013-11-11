redis = require('../redis').connection
request = require 'request'

app = require("#{__dirname}/../app.coffee").app
port = 3333

describe 'app', ->
  before (done) ->
    app.REDIS_NAMESPACE = 'test:karma'
    redis.deleteKeys(app.REDIS_NAMESPACE, done)

  before (done) ->
    app.listen port, (error) ->
      if error
        done error
      else
        done()

  describe '/', ->
    it 'responds with Karma App', (done) ->
      request.get url('/'), (error, response, body) ->
        expect(body).to.eq 'Karma app.'
        done()

  describe '/leaderboard', ->
    before ->
      app.store().upvote 'laser'
      app.store().upvote 'laser'
      app.store().upvote 'laser'
      app.store().upvote 'dickeyxxx'
      app.store().upvote 'dickeyxxx'

    it 'returns the entries ordered', (done) ->
      request.get url('/leaderboard'), (error, response, body) ->
        entries = JSON.parse body

        expect(entries[0]).to.eql
          name: 'laser'
          karma: 3

        expect(entries[1]).to.eql
          name: 'dickeyxxx'
          karma: 2

        done()

  describe '/upvote', ->
    it 'increments karma of the specified user', (done) ->
      options =
        url: url '/upvote'
        json:
          user: 'michaelavila'

      request.post options, (error, response, body) ->
        app.store().karma 'michaelavila', (karma) ->
          expect(karma).to.eq 1
          done()

url = (path) -> "http://127.0.0.1:3333#{path}"
