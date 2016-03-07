require! {
  'mongodb' : {MongoClient, ObjectID}
  'nitroglycerin' : N
  'prelude-ls' : {any}
  'util'
}
env = require('get-env')('test')


collection = null

module.exports =

  before-all: (done) ->
    mongo-db-name = "space-tweet-tweets-#{env}"
    MongoClient.connect "mongodb://localhost:27017/#{mongo-db-name}", N (mongo-db) ->
      collection := mongo-db.collection 'tweets'
      console.log "MongoDB '#{mongo-db-name}' connected"
      done!


  'tweets.get-details': (query, {reply}) ->
    try
      mongo-query = id-to-mongo query
    catch
      console.log "the given query (#{query}) contains an invalid id"
      return reply 'tweets.not-found', query
    collection.find(mongo-query).to-array N (tweets) ->
      if tweets.length is 0
        console.log "tweet '#{util.inspect mongo-query}' not found"
        return reply 'tweets.not-found', query
      tweet = tweets[0]
      mongo-to-id tweet
      console.log "reading tweet '#{tweet.content}' (#{tweet.id})"
      reply 'tweets.details', tweet


  'tweets.update': (tweet-data, {reply}) ->
    try
      id = new ObjectID tweet-data.id
    catch
      console.log "the given query (#{tweet-data}) contains an invalid id"
      return reply 'tweets.not-found', id: tweet-data.id
    delete tweet-data.id
    collection.update-one {_id: id}, {$set: tweet-data}, N (result) ->
      switch result.modified-count
        | 0  =>
            console.log "tweet '#{id}' not updated because it doesn't exist"
            return reply 'tweets.not-found'
        | _  =>
            collection.find(_id: id).to-array N (tweets) ->
              tweet = tweets[0]
              mongo-to-id tweet
              console.log "updating tweet '#{tweet.content}' (#{tweet.id})"
              reply 'tweets.updated', tweet


  'tweets.delete': (query, {reply}) ->
    try
      id = new ObjectID query.id
    catch
      console.log "the given query (#{util.inspect query}) contains an invalid id"
      return reply 'tweets.not-found', id: query.id
    collection.find(_id: id).to-array N (tweets) ->
      if tweets.length is 0
        console.log "tweet '#{id}' not deleted because it doesn't exist"
        return reply 'tweets.not-found', query
      tweet = tweets[0]
      mongo-to-id tweet
      collection.delete-one _id: id, N (result) ->
        if result.deleted-count is 0
          console.log "tweet '#{id}' not deleted because it doesn't exist"
          return reply 'tweets.not-found', query
        console.log "deleting tweet '#{tweet.content}' (#{tweet.id})"
        reply 'tweets.deleted', tweet


  'tweets.create': (tweet-data, {reply}) ->
    | empty-content tweet-data  =>
        console.log 'Cannot create tweet: Content cannot be blank'
        return reply 'tweets.not-created', error: 'Content cannot be blank'
    collection.insert-one tweet-data, (err, result) ->
      if err
        console.log "Error creating tweet: #{err}"
        return reply 'tweets.not-created', error: err
      console.log "creating tweets"
      reply 'tweets.created', mongo-to-id(result.ops[0])


  'tweets.create-many': (tweets, {reply}) ->
    | any-empty-contents tweets  =>  return reply 'tweets.not-created', error: 'Content cannot be blank'
    collection.insert tweets, (err, result) ->
      | err  =>  return reply 'tweets.not-created-many', error: err
      reply 'tweets.created-many', count: result.inserted-count


  'tweets.list': (query, {reply}) ->
    mongo-query = if query?.owner_id
      {"owner_id": query.owner_id.to-string!}
    else
      {}
    collection.find(mongo-query).to-array N (tweets) ->
      mongo-to-ids tweets
      console.log "listing tweets: #{tweets.length} found"
      reply 'tweets.listed', {count: tweets.length, tweets}



function any-empty-contents tweets
  any empty-content, tweets


function empty-content tweet
  tweet.content.length is 0


function id-to-mongo query
  result = {[k,v] for k,v of query}
  if result.id
    result._id = new ObjectID result.id
    delete result.id
  result


function mongo-to-id entry
  entry.id = entry._id
  delete entry._id
  entry


function mongo-to-ids entries
  for entry in entries
    mongo-to-id entry
