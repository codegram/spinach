Feature: Feature name guessing
  In order to be faster writing steps
  As a test writer
  I want the names of the features to be guessed from the feature class name

  Scenario: Basic guess
    Given I am writing a feature called "My cool feature"
    And I write a class named "MyCoolFeature"
    When I run spinach
    Then I want "MyCoolFeature" class to be used to run it
