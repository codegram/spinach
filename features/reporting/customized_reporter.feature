Feature: Use customized reporter
  As a developer
  I want to use a different reporter
  So I can have different output

  Scenario: Happy path
    Given I have a feature that has no error or failure
    When I run it using the new reporter
    Then I see the desired output

  Scenario: Multiple reporters
    Given I have a feature that has one failure
    When I run it using two custom reporters
    Then I see one reporter's output on the screen
    And I see the other reporter's output in a file