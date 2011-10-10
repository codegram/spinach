Feature: Display run summary
  As a developer
  I want spinach to display a summary of steps statuses
  So I can easyly know general features status

  Scenario: Display run summary at the end of features run
    Given I have a feature that has some successful, undefined, failed and error steps
    When I run it
    Then I should see a summary with steps status information
