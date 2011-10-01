Feature: Exit status
  In order to receive a standard exit code
  As a developer
  I want spinach to return exit status properly

  Scenario: It succeeds
    Given I have a feature that has no error or failure
    When I run it
    Then the exit status should be 0

  Scenario: It fails
    Given I have a feature that has a failure
    When I run it
    Then the exit status should be 1
