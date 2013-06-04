Feature: Fail fast option
  In order to save running time
  As a developer
  I want spinach to fail fast when I so desire

  Scenario: fail fast
    Given I have a feature that has a failure
    And I have a feature that has no error or failure
    When I run both of them with fail-fast option
    Then the tests stop at the first one
