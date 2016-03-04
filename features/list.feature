Feature: Listing all tweets

  As a developer working on an application that uses tweets of content assigned to tweets
  I want to have an easy way to get a list of all tweet for a tweet
  So that I can display overview pages.

  Rules:
  - returns all tweets currently stored


  Background:
    Given an ExoCom server
    And an instance of this service


  Scenario: no tweets exist in the database
    When sending the message "tweets.list" with the payload:
      """
      owner_id: 1
      """
    Then the service replies with "tweets.listed" and the payload:
      """
      count: 0
      tweets: []
      """


  Scenario: tweets exist in the database
    Given the service contains the tweets:
      | OWNER_ID | CONTENT                 |
      | 1        | Hello world!            |
      | 1        | Hello again!            |
      | 2        | Tweet from another user |
    When sending the message "tweets.list" with the payload:
      """
      owner_id: 1
      """
    Then the service replies with "tweets.listed" and the payload:
      """
      count: 2
      tweets: [
        * content: 'Hello world!'
          id: /\d+/
          owner_id: "1"
        * content: 'Hello again!'
          id: /\d+/
          owner_id: "1"
      ]
      """
