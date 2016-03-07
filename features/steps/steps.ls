require! {
  'chai' : {expect}
  'dim-console'
  'exocom-mock' : ExoComMock
  'exoservice' : ExoService
  'jsdiff-console'
  'livescript'
  'nitroglycerin' : N
  'port-reservation'
  'record-http' : HttpRecorder
  'request'
  'wait' : {wait-until}
}


module.exports = ->

  @Given /^an ExoCom server$/, (done) ->
    port-reservation
      ..get-port N (@exocom-port) ~>
        @exocom = new ExoComMock
          ..listen @exocom-port, done


  @Given /^an instance of this service$/, (done) ->
    port-reservation
      ..get-port N (@service-port) ~>
        @exocom.register-service name: 'tweets', port: @service-port
        @process = new ExoService service-name: 'tweets', exocom-port: @exocom.port, exorelay-port: @service-port
          ..listen!
          ..on 'online', -> done!


  @Given /^the service contains the tweets:$/, (table, done) ->
    tweets = [{[key.to-lower-case!, value] for key, value of record} for record in table.hashes!]
    @exocom
      ..send-message service: 'tweets', name: 'tweets.create-many', payload: tweets
      ..wait-until-receive done



  @When /^sending the message "([^"]*)"$/, (message) ->
    @exocom.send-message service: 'tweets', name: message


  @When /^sending the message "([^"]*)" with the payload:$/, (message, payload, done) ->
    @fill-in-tweet-ids payload, (filled-payload) ~>
      if filled-payload[0] is '['   # payload is an array
        eval livescript.compile "payload-json = #{filled-payload}", bare: true, header: no
      else                          # payload is a hash
        eval livescript.compile "payload-json = {\n#{filled-payload}\n}", bare: true, header: no
      @exocom.send-message service: 'tweets', name: message, payload: payload-json
      done!



  @Then /^the service contains no tweets$/, (done) ->
    @exocom
      ..send-message service: 'tweets', name: 'tweets.list', payload: { owner_id: '1' }
      ..wait-until-receive ~>
        expect(@exocom.received-messages![0].payload.count).to.equal 0
        done!


  @Then /^the service now contains the tweets:$/, (table, done) ->
    @exocom
      ..send-message service: 'tweets', name: 'tweets.list', payload: { owner_id: '1' }
      ..wait-until-receive ~>
        actual-tweets = @remove-ids @exocom.received-messages![0].payload.tweets
        expected-tweets = [{[key.to-lower-case!, value] for key, value of tweet} for tweet in table.hashes!]
        jsdiff-console actual-tweets, expected-tweets, done


  @Then /^the service replies with "([^"]*)" and the payload:$/, (message, payload, done) ->
    eval livescript.compile "expected-payload = {\n#{payload}\n}", bare: yes, header: no
    @exocom.wait-until-receive ~>
      actual-payload = @exocom.received-messages![0].payload
      jsdiff-console @remove-ids(actual-payload), @remove-ids(expected-payload), done
