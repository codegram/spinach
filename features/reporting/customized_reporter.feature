Feature: Use customized reporter
  As a developer
  I want to use a different reporter
  So I can have different output

  Scenario: Happy path
    Given I have a feature that has no error or failure
    When I run it using the new reporter
    Then I see the desired output
