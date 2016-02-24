require! {
  'mongodb' : {MongoClient}
  'nitroglycerin' : N
  'prelude-ls' : {any}
}
debug = require('debug')('snippets-service')
env = require('get-env')('test')


collection = null

module.exports =

  before-all: (done) ->
    MongoClient.connect "mongodb://localhost:27017/space-tweet-snippets-#{env}", N (mongo-db) ->
      collection := mongo-db.collection 'snippets'
      debug 'MongoDB connected'
      done!


  'snippets.create': (snippet-data, {reply}) ->
    | empty-content snippet-data  =>  return reply 'snippets.not-created', error: 'Content cannot be blank'
    collection.insert-one snippet-data, (err, result) ->
      | err  =>  return reply 'snippets.not-created', error: err
      reply 'snippets.created', mongo-to-id(result.ops[0])


  'snippets.create-many': (snippets, {reply}) ->
    | any-empty-contents snippets  =>  return reply 'snippets.not-created', error: 'Content cannot be blank'
    collection.insert snippets, (err, result) ->
      | err  =>  return reply 'snippets.not-created-many', error: err
      reply 'snippets.created-many', count: result.inserted-count


  'snippets.list': (_, {reply}) ->
    collection.find({}).to-array N (snippets) ->
      mongo-to-ids snippets
      reply 'snippets.listed', {count: snippets.length, snippets}



function empty-content snippet
  console.log snippet
  snippet.content.length is 0


function any-empty-contents snippets
  any empty-content, snippets


function mongo-to-id entry
  entry.id = entry._id ; delete entry._id
  entry


function mongo-to-ids entries
  for entry in entries
    mongo-to-id entry
