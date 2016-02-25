require! {
  '../support/dim-console'
  'chai' : {expect}
  'exocomm-mock' : ExoCommMock
  'exoservice' : ExoService
  'jsdiff-console'
  'livescript'
  'nitroglycerin' : N
  'port-reservation'
  'record-http' : HttpRecorder
  'request'
  '../support/remove-ids' : {remove-ids}
  'wait' : {wait-until}
}


module.exports = ->

  @Given /^an ExoComm server$/, (done) ->
    port-reservation
      ..get-port N (@exocomm-port) ~>
        @exocomm = new ExoCommMock
          ..listen @exocomm-port, done


  @Given /^an instance of this service$/, (done) ->
    port-reservation
      ..get-port N (@service-port) ~>
        @exocomm.register-service name: 'tweets', port: @service-port
        @process = new ExoService service-name: 'tweets', exocomm-port: @exocomm.port, exorelay-port: @service-port
          ..listen!
          ..on 'online', -> done!


  @Given /^the service contains the tweets:$/, (table, done) ->
    tweets = [{[key.to-lower-case!, value] for key, value of record} for record in table.hashes!]
    @exocomm
      ..send-message service: 'tweets', name: 'tweets.create-many', payload: tweets
      ..wait-until-receive done



  @When /^sending the message "([^"]*)"$/, (message) ->
    @exocomm
      ..send-message service: 'tweets', name: message


  @When /^sending the message "([^"]*)" with the payload:$/, (message, payload) ->
    if payload[0] is '['
      eval livescript.compile "payload-json = #{payload}", bare: true, header: no
    else
      eval livescript.compile "payload-json = {\n#{payload}\n}", bare: true, header: no
    @exocomm
      ..send-message service: 'tweets', name: message, payload: payload-json


  @Then /^the service contains no tweets/, (done) ->
    @exocomm
      ..send-message service: 'tweets', name: 'tweets.list', payload: { owner: '1' }
      ..wait-until-receive ~>
        expect(@exocomm.received-messages![0].payload.count).to.equal 0
        done!


  @Then /^the service contains the tweet accounts:$/, (table, done) ->
    @exocomm
      ..send-message service: 'tweets', name: 'tweets.list'
      ..wait-until-receive ~>
        actual-tweet = remove-ids @exocomm.received-messages![0].payload.tweets
        expected-tweets = [{[key.to-lower-case!, value] for key, value of tweet} for tweet in table.hashes!]
        jsdiff-console actual-tweets, expected-tweets, done


  @Then /^the service replies with "([^"]*)" and the payload:$/, (message, payload, done) ->
    @exocomm.wait-until-receive ~>
      actual-payload = @exocomm.received-messages![0].payload
      eval livescript.compile "expected-payload = {\n#{payload}\n}", bare: yes, header: no
      jsdiff-console remove-ids(actual-payload), remove-ids(expected-payload), done
