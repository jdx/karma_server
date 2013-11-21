store = require "#{__dirname}/../../app/store.coffee"
redis = require('../../redis').connection
timekeeper = require('timekeeper')

describe 'Store', ->
  before (done) ->
    @TEST_NAMESPACE = 'test:karma'
    redis.deleteKeys(@TEST_NAMESPACE, done)
    @karmaStore = new store.Store @TEST_NAMESPACE

  describe '#leaderboard', ->
    it 'can be empty', (done) ->
      @karmaStore.leaderboard (entries) ->
        expect(entries).to.eql []
        done()

    context 'given entries', ->
      before ->
        redis.zincrby "#{@TEST_NAMESPACE}:leaderboard", 1, 'user2'
        redis.zincrby "#{@TEST_NAMESPACE}:leaderboard", 1, 'user1'
        redis.zincrby "#{@TEST_NAMESPACE}:leaderboard", 1, 'user2'

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
      redis.zincrby "#{@TEST_NAMESPACE}:leaderboard", 4, 'user3'

    it 'returns the correct karma', (done) ->
      @karmaStore.karma 'user3', (karma) ->
        expect(karma).to.eq 4
        done()

  describe '#upvote', ->

    date = new Date(1330688329321)
    before ->
      timekeeper.freeze(date)
    after ->
      timekeeper.reset()

    it 'increments a users karma by 1', (done) ->
      @karmaStore.upvote 'someuser', null, =>
        @karmaStore.karma 'someuser', (karma) ->
          expect(karma).to.eq 1
          done()

    it 'adds a record to the log', (done) ->
      @karmaStore.upvote 'someuser', 'is awesome', =>
        @karmaStore.upvotes (upvotes) ->
          expect(upvotes[0]).to.eql { user: 'someuser', comment: 'is awesome', timestamp: '2012-03-02T11:38:49.321Z' }
          done()
