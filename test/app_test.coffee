redis = require('redis-url').connect()
request = require 'request'

app = require("#{__dirname}/../app.coffee").app
port = 3333

url = (path) -> "http://127.0.0.1:3333#{path}"

describe 'app', ->
  before ->
    app.REDIS_LEADERBOARD_KEY = 'test:karma:leaderboard'
    redis.del app.REDIS_LEADERBOARD_KEY

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
      redis.zincrby app.REDIS_LEADERBOARD_KEY, 1, 'user2'
      redis.zincrby app.REDIS_LEADERBOARD_KEY, 1, 'user1'
      redis.zincrby app.REDIS_LEADERBOARD_KEY, 1, 'user2'

    it 'returns the entries ordered', (done) ->
      request.get url('/leaderboard'), (error, response, body) ->
        entries = JSON.parse body

        expect(entries[0]).to.eql
          name: 'user2'
          karma: 2

        expect(entries[1]).to.eql
          name: 'user1'
          karma: 1

        done()

  describe '/upvote', ->
    it 'increments karma of the specified user', (done) ->
      options =
        url: url '/upvote'
        json:
          user: 'someuser'

      request.post options, (error, response, body) ->
        redis.zrange app.REDIS_LEADERBOARD_KEY, 0, -1, "WITHSCORES", (code, leaderboard) ->
          entries = leaderboard.reverse()
          for index in [0..entries.length] by 2
            if entries[index+1] is 'someuser'
              expect(+entries[index]).to.eq 1
              done()
