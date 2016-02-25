Feature: Creating multiple tweets

  As an ExoService application
  I want to be able to create multiple tweets in one transaction
  So that I don't have to send and receive so many messages and remain performant.

  Rules:
  - send the message "tweets.create-many" to create several tweets at once
  - payload is an array of tweet data
  - when successful, the service replies with "tweets.created"
    and the newly created account
  - when there is an error, the service replies with "tweets.not-created"
    and a message describing the error


  Background:
    Given an ExoComm server
    And an instance of this service


  Scenario: creating valid tweets
    When sending the message "tweets.create-many" with the payload:
      """
      [
        * content: 'Monday'
        * content: 'Tuesday'
      ]
      """
    Then the service replies with "tweets.created" and the payload:
      """
      count: 2
      """
    And the service contains the tweets:
      | CONTENT |
      | Monday  |
      | Tuesday |


  Scenario: trying to create tweets with empty content
    When sending the message "tweets.create-many" with the payload:
      """
      [
        * content: 'Monday'
        * content: ''
      ]
      """
    Then the service replies with "tweets.not-created" and the payload:
      """
      error: 'Content cannot be blank'
      """
    And the service contains no tweets
