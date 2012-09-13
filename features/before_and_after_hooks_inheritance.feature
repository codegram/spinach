Feature: Before and after hooks inheritance
  In order to maintain the super classes' before and after code
  As a developer
  I want to chain the before and after blocks

  Scenario: Happy path
    Then I can see the variable setup in the super class before hook
    And I can see the variable being overridden in the subclass

  Scenario: Inter-dependency - after hook cleans up (after happy path)
    Then I can see the variable setup in the super class before hook
    And I can see the variable being overridden in the subclass
