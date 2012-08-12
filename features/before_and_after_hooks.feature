Feature: Before and after hooks
  In order to setup and clean the test environment for a single feature
  As a developer
  I want to be able to use before and after hooks within the step class

  Scenario: Happy path
    Then I can verify the variable setup in the before hook

  Scenario: Inter-dependency - after hook cleans up (after happy path)
    Then I can verify the variable setup in the before hook
