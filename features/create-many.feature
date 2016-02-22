Feature: Creating multiple snippets

  As an ExoService application
  I want to be able to create multiple snippets in one transaction
  So that I don't have to send and receive so many messages and remain performant.

  Rules:
  - send the message "snippets.create-many" to create several snippets at once
  - payload is an array of snippet data
  - when successful, the service replies with "snippets.created"
    and the newly created account
  - when there is an error, the service replies with "snippets.not-created"
    and a message describing the error


  Background:
    Given an ExoComm server
    And an instance of this service


  Scenario: creating valid snippets
    When sending the message "snippets.create-many" with the payload:
      """
      * content: 'Monday'
      * content: 'Tuesday'
      """
    Then the service replies with "snippets.created" and the payload:
      """
      * id: /\d+/
        content: 'Monday'
      * id: /\d+/
        content: 'Tuesday'
      """
    And the service contains the snippets:
      | CONTENT |
      | Monday  |
      | Tuesday |
