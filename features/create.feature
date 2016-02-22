Feature: Creating snippets

  Rules:
  - snippets must have a name
  - when successful, the service replies with "snippets.created"
    and the newly created account
  - when there is an error, the service replies with "snippets.not-created"
    and a message describing the error


  Background:
    Given an ExoComm server
    And an instance of this service


  Scenario: creating a valid user account
    When sending the message "snippets.create" with the payload:
      """
      content: 'Hello world'
      """
    Then the service replies with "snippets.created" and the payload:
      """
      id: /\d+/
      name: 'Hello world'
      """
    And the service contains the snippets:
      | CONTENT     |
      | Hello world |


  Scenario: trying to create a snippet with empty content
    When sending the message "snippets.create" with the payload:
      """
      content: ''
      """
    Then the service replies with "snippets.not-created" and the payload:
      """
      error: 'Content cannot be blank'
      """
    And the service contains no snippets
