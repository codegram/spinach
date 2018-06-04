Feature: Display run summary
  As a developer
  I want spinach to display a summary of steps statuses
  So I can easily know general features status

  Scenario: Display run summary at the end of features run without randomization
    Given I have a feature that has some successful, undefined, failed and error steps

    When I run it without randomization
    Then I should see a summary with steps status information
    And I shouldn't see a randomization seed

  Scenario: Display run summary at the end of features run with randomization
    Given I have a feature that has some successful, undefined, failed and error steps

    When I run it with randomization
    Then I should see a summary with steps status information
    And I should see a randomization seed

  Scenario: Display run summary at the end of features run with a randomization seed
    Given I have a feature that has some successful, undefined, failed and error steps

    When I run it with a specific randomization seed
    Then I should see a summary with steps status information
    And I should see that specific randomization seed
