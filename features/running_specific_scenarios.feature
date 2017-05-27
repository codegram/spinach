Feature: Running Specific Scenarios
  In order to test only specific scenarios
  As a developer
  I want spinach to run only the scenarios I specify

  Scenario: Specifying line numbers
    Given I have a feature with 2 scenarios
    When I specify that only the second should be run
    Then One will succeed and none will fail

  Scenario: Including tags
    Given I have a tagged feature with 2 scenarios
    When I include the tag of the failing scenario
    Then None will succeed and one will fail

  Scenario: Excluding tags
    Given I have a tagged feature with 2 scenarios
    When I exclude the tag of the passing scenario
    Then None will succeed and one will fail

  Scenario: Combining tags
    Given I have a tagged feature with 2 scenarios
    When I include the tag of the feature and exclude the tag of the failing scenario
    Then One will succeed and none will fail
