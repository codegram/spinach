Feature: Feature Hooks and Tags
  In order to run only the appropriate setup and teardown code
  As a developer
  I want spinach to only run feature hooks if those features would be run under the tags I provided

  Scenario: No tags specified
    Given I have a tagged feature with an untagged scenario
    And I have an untagged feature with a tagged scenario
    When I don't specify tags
    Then all the feature hooks should have run

  Scenario: Tags specified
    Given I have a tagged feature with an untagged scenario
    And I have an untagged feature with a tagged scenario
    When I specify a tag the features and scenarios are tagged with
    Then all the feature hooks should have run

  Scenario: Tags excluded
    Given I have a tagged feature with an untagged scenario
    And I have an untagged feature with a tagged scenario
    When I exclude a tag the features and scenarios are tagged with
    Then no feature hooks should have run
