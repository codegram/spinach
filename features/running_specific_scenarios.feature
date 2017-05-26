Feature: Running Specific Scenarios
  In order to test only specific scenarios
  As a developer
  I want spinach to run only the scenarios I specify

  Scenario: Specifying line numbers
    Given I have a feature with 2 passing scenarios
    When I specify that only the second should be run
    Then Only the second should be run
