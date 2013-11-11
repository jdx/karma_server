store = require "#{__dirname}/../../app/store.coffee"
redis = require('redis-url').connect()

describe 'Store', ->
  before ->
    @TEST_STORE_KEY = 'test:karma:leaderboard'
    redis.del @TEST_STORE_KEY
    @karmaStore = new store.Store @TEST_STORE_KEY

  describe '#leaderboard', ->
    it 'can be empty', (done) ->
      @karmaStore.leaderboard (entries) ->
        expect(entries).to.eql []
        done()

    context 'given entries', ->
      before ->
        redis.zincrby @TEST_STORE_KEY, 1, 'user2'
        redis.zincrby @TEST_STORE_KEY, 1, 'user1'
        redis.zincrby @TEST_STORE_KEY, 1, 'user2'

      it 'orders the entries', (done) ->
        @karmaStore.leaderboard (entries) ->
          expect(entries[0]).to.eql
            name: 'user2'
            karma: 2

          expect(entries[1]).to.eql
            name: 'user1'
            karma: 1

          done()

  describe '#karma', ->
    before ->
      redis.zincrby @TEST_STORE_KEY, 4, 'user3'

    it 'returns the correct karma', (done) ->
      @karmaStore.karma 'user3', (karma) ->
        expect(karma).to.eq 4
        done()

  describe '#upvote', ->
    before ->
      redis.del @TEST_STORE_KEY

    it 'increments a users karma by 1', (done) ->
      @karmaStore.upvote 'someuser'

      @karmaStore.karma 'someuser', (karma) ->
        expect(karma).to.eq 1
        done()
