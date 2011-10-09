Feature: RSpec compatibility
  In order to use rspec in my step definitions
  As a RSpec developer
  I want spinach to detect my rspec failures as failures instead of errors

  Scenario: An expectation fails
    Given I have a feature with some failed expectations
    When I run "spinach" with rspec
    Then I should see the failure count along with their messages
