Feature: Show step source location
  As a developer
  I want spinach to give me every step source location in output
  So I can easily know where I defined a step

  Scenario: Show class steps source location in output when all is ok
    Given I have a feature that has no error or failure
    When I run it
    Then I should see the source location of each step of every scenario

  Scenario: Show in output the source location of external modules steps
    Given I have a feature that has no error or failure and use external steps
    When I run it
    Then I should see the source location of each step, even external ones

  Scenario: Show class steps source location in output even when there is an error
    Given I have a feature that has an error
    When I run it
    Then I should see the source location of each step, even ones with errors

  Scenario: Show class steps source location in output even when there is a failure
    Given I have a feature that has a failure
    When I run it
    Then I should see the source location of each step, even ones with failures
