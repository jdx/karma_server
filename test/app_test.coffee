redis = require('../redis').connection
request = require 'request'

app = require("#{__dirname}/../app.coffee").app
port = 3333

describe 'app', ->
  beforeEach (done) ->
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
    beforeEach ->
      app.store().upvote 'laser'
      app.store().upvote 'laser'
      app.store().upvote 'laser'
      app.store().upvote 'dickeyxxx'
      app.store().upvote 'dickeyxxx'

    describe 'authenticated', ->
      it 'returns 401 Unauthorized', (done) ->
        request.get url('/leaderboard'), (error, response) ->
          expect(response.statusCode).to.eq 401
          done()

    describe 'authenticated', ->
      before (done) ->
        options =
          url: url('/login')
          username: 'dickeyxxx'
          password: 'passcode'
        request.post url('/login'), ->
          done()

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
        json: { user: 'michaelavila' }

      request.post options, ->
        app.store().karma 'michaelavila', (karma) ->
          expect(karma).to.eq 1
          done()

  describe '/upvotes', ->
    it 'gets the recent upvotes', (done) ->
      options =
        url: url '/upvotes'

      request.get options, (error, response, body) ->
        expect(body.length).to.eq 2
        done()

url = (path) -> "http://127.0.0.1:3333#{path}"
