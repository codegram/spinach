Feature: Pending steps
  In order to save running time
  As a developer
  I want spinach to fail fast when I so desire

  Scenario: multiple scenarios
    Given I have a feature that has a pending step
    When I run the feature
    Then the test stops at the pending step and reported as such
