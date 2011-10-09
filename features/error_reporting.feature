Feature: Error reporting
  In order to receive a clear output and chase my errors
  As a developer
  I want spinach to give me a comprehensive error reporting

  Scenario: Error reporting without backtrace
    Given I have a feature with some failures
    When I run "spinach"
    Then I should see the failure count along with their messages

  Scenario: Error reporting with backtrace
    Given I have a feature with some failures
    When I run "spinach --backtrace"
    Then I should see the error count along with their messages and backtrace
