Feature: Randomizing Features & Scenarios
  In order to ensure my tests aren't dependent
  As a developer
  I want spinach to randomize features and scenarios (but not steps)

  Scenario: Randomizing the run without specifying a seed
    Given I have 2 features with 2 scenarios each
    When I randomize the run without specifying a seed
    Then The features and scenarios are run
    And The runner output shows a seed

  Scenario: Specifying the seed
    Given I have 2 features with 2 scenarios each
    When I specify the seed for the run
    Then The features and scenarios are run in a different order
    And The runner output shows the seed
