redis = require('redis-url').connect()

class Store

  constructor: (@key) ->

  leaderboard: (callback) ->
    redis.zrange @key, 0, -1, "WITHSCORES", (code, leaderboard) ->
      list = []
      entries = leaderboard.reverse()
      for index in [0..entries.length-1] by 2
        list.push
          name: entries[index+1]
          karma: +entries[index]
      callback list

  karma: (username, callback) ->
    @leaderboard (entries) ->
      for entry in entries
        continue unless entry['name'] is username

        callback entry['karma']
        break

  upvote: (username) ->
    redis.zincrby @key, 1, username

exports.Store = Store
