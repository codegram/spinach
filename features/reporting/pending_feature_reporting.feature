Feature: Pending feature reporting
  In order to be aware of what features are still pending
  As a developer
  I want spinach to tell me which of them I still need to implement

  Scenario: Pending feature
    Given I've written a pending scenario
    When I run spinach
    Then I should see a message telling me that there's a pending scenario
    And I should see a message showing me the reason of the pending scenario
 
 Scenario: Step definition without body
    Given I've written a step definition without body
    When I run spinach
    Then I should see a message telling me that there's a pending scenario
    And I should see a message showing me the default reason of the pending scenario
