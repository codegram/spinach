Feature: Show step source location
  As a developer
  I want spinach to give me every step source location in output
  So I can easyly know where I defined a step

  Scenario: Show class steps source location in output
    Given I have a feature that has no error or failure
    When I run it
    Then I should see the source location of each step of every scenario

  Scenario: Show in output the source location of external modules steps
    Given I have a feature that has no error or failure and use external steps
    When I run it
    Then I should see the source location of each step, even external ones
