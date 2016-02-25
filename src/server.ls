require! {
  'mongodb' : {MongoClient}
  'nitroglycerin' : N
  'prelude-ls' : {any}
}
debug = require('debug')('tweets-service')
env = require('get-env')('test')


collection = null

module.exports =

  before-all: (done) ->
    MongoClient.connect "mongodb://localhost:27017/space-tweet-tweets-#{env}", N (mongo-db) ->
      collection := mongo-db.collection 'tweets'
      debug 'MongoDB connected'
      done!


  'tweets.create': (tweet-data, {reply}) ->
    | empty-content tweet-data  =>  return reply 'tweets.not-created', error: 'Content cannot be blank'
    collection.insert-one tweet-data, (err, result) ->
      | err  =>  return reply 'tweets.not-created', error: err
      reply 'tweets.created', mongo-to-id(result.ops[0])


  'tweets.create-many': (tweets, {reply}) ->
    | any-empty-contents tweets  =>  return reply 'tweets.not-created', error: 'Content cannot be blank'
    collection.insert tweets, (err, result) ->
      | err  =>  return reply 'tweets.not-created-many', error: err
      reply 'tweets.created-many', count: result.inserted-count


  'tweets.list': ({owner}, {reply}) ->
    collection.find({"owner_id": owner.to-string!}).to-array N (tweets) ->
      mongo-to-ids tweets
      reply 'tweets.listed', {count: tweets.length, tweets}



function empty-content tweet
  tweet.content.length is 0


function any-empty-contents tweets
  any empty-content, tweets


function mongo-to-id entry
  entry.id = entry._id ; delete entry._id
  entry


function mongo-to-ids entries
  for entry in entries
    mongo-to-id entry
