Feature: Undefined feature reporting
  In order to be aware of what features I've still not defined
  As a developer
  I want spinach to tell me which of them I'm missing

  Scenario: Undefined feature
    Given I've written a feature but not its steps
    When I run spinach
    Then I should see a message telling me that there's an undefined feature
