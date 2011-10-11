Feature: Automatic feature generation
  In order to be faster writing features
  As a developer
  I want spinach to automatically generate features for me

  Scenario: Missing feature
    Given I have defined a "Cheezburger can I has" feature
    When I run spinach with "--generate"
    Then I a feature should exist named "features/steps/cheezburger_can_i_has.rb"
    And that feature should have the example feature steps
