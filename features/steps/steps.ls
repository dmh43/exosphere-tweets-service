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
        @exocomm.register-service name: 'snippets', port: @service-port
        @process = new ExoService service-name: 'snippets', exocomm-port: @exocomm.port, exorelay-port: @service-port
          ..listen!
          ..on 'online', -> done!


  @Given /^the service contains the snippets:$/, (table, done) ->
    snippets = [{[key.to-lower-case!, value] for key, value of record} for record in table.hashes!]
    @exocomm
      ..send-message service: 'snippets', name: 'snippets.create-many', payload: snippets
      ..wait-until-receive done



  @When /^sending the message "([^"]*)"$/, (message) ->
    @exocomm
      ..send-message service: 'snippets', name: message


  @When /^sending the message "([^"]*)" with the payload:$/, (message, payload) ->
    if payload[0] is '['
      eval livescript.compile "payload-json = #{payload}", bare: true, header: no
    else
      eval livescript.compile "payload-json = {\n#{payload}\n}", bare: true, header: no
    @exocomm
      ..send-message service: 'snippets', name: message, payload: payload-json


  @Then /^the service contains no snippets/, (done) ->
    @exocomm
      ..send-message service: 'snippets', name: 'snippets.list'
      ..wait-until-receive ~>
        expect(@exocomm.received-messages![0].payload.count).to.equal 0
        done!


  @Then /^the service contains the snippet accounts:$/, (table, done) ->
    @exocomm
      ..send-message service: 'snippets', name: 'snippets.list'
      ..wait-until-receive ~>
        actual-snippets = remove-ids @exocomm.received-messages![0].payload.snippets
        expected-snippets = [{[key.to-lower-case!, value] for key, value of snippet} for snippet in table.hashes!]
        jsdiff-console actual-snippets, expected-snippets, done


  @Then /^the service replies with "([^"]*)" and the payload:$/, (message, payload, done) ->
    @exocomm.wait-until-receive ~>
      actual-payload = @exocomm.received-messages![0].payload
      eval livescript.compile "expected-payload = {\n#{payload}\n}", bare: yes, header: no
      jsdiff-console remove-ids(actual-payload), remove-ids(expected-payload), done
