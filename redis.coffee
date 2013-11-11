if (process.env.REDIS_URL)
  rtg   = require("url").parse(process.env.REDIS_URL)
  redis = require("redis").createClient(rtg.port, rtg.hostname)
  redis.auth(rtg.auth.split(":")[1])
else
  redis = require("redis").createClient()

redis.deleteKeys = (namespace, callback) ->
  redis.keys "#{namespace}*", (err, keys) ->
    multi = redis.multi()
    multi.del(key) for key in keys
    multi.exec -> callback()

exports.connection = redis
