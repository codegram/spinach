Feature: Background
  In order to avoid duplication of Steps in Scenarios
  As a developer
  I want to describe the background Steps once
  
  Background:
    Given Spinach has Background support

  Scenario: Using Background
    And another step in this scenario
    When I run this Scenario
    Then the background step should have been executed
    And the scenario step should have been executed
