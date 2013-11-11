redis = require('../redis').connection

class Store

  constructor: (@namespace) ->

  leaderboard: (callback) ->
    redis.zrange "#{@namespace}:leaderboard", 0, -1, "WITHSCORES", (code, leaderboard) ->
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

  upvote: (username, comment, callback) ->
    multi = redis.multi()
    multi.lpush "#{@namespace}:upvotes:#{username}", comment
    multi.zincrby "#{@namespace}:leaderboard", 1, username
    multi.exec -> callback?()

  getUpvotes: (username, callback) ->
    redis.lrange "#{@namespace}:upvotes:#{username}", 0, -1, (err, upvotes) ->
      callback(upvotes)

exports.Store = Store
