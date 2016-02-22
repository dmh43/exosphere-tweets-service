Feature: Listing all snippets

  As a developer working on an application that uses snippets of content assigned to users
  I want to have an easy way to get a list of all snippets for a user
  So that I can display overview pages.

  Rules:
  - returns all snippets currently stored


  Background:
    Given an ExoComm server
    And an instance of this service


  Scenario: no snippets exist in the database
    When sending the message "snippets.list" with the payload:
      """
      owner: 1
      """
    Then the service replies with "snippets.listed" and the payload:
      """
      count: 0
      snippets: []
      """


  Scenario: snippets exist in the database
    Given the service contains the snippets:
      | OWNER | CONTENT                   |
      | 1     | Hello world!              |
      | 1     | Hello again!              |
      | 2     | Snippet from another user |
    When sending the message "snippets.list" with the payload:
      """
      owner: 1
      """
    Then the service replies with "snippets.listed" and the payload:
      """
      count: 2
      snippets: [
        * content: 'Hello world!'
          id: /\d+/
          owner_id: 1
        * content: 'Hello again!'
          id: /\d+/
          owner_id: 1
      ]
      """
