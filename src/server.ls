require! {
  'mongodb' : {MongoClient}
  'nitroglycerin' : N
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
    | not snippet-data.name  =>  return reply 'snippets.not-created', error: 'Name cannot be blank'
    collection.insert-one snippet-data, (err, result) ->
      | err  =>  return reply 'snippets.not-created', error: err
      user = result.ops[0]
      user.id = user._id ; delete user._id
      reply 'snippets.created', user


  'snippets.create-many': (snippets, {reply}) ->
    collection.insert snippets, (err, result) ->
      | err  =>  return reply 'snippets.not-created-many', error: err
      reply 'snippets.created-many', count: result.inserted-count


  'snippets.list': (_, {reply}) ->
    collection.find({}).to-array N (snippets) ->
      for user in snippets
        user.id = user._id ; delete user._id
      reply 'snippets.listed', {count: snippets.length, snippets}
