Feature: User logs in

  Scenario: User logs in
    Given I am not logged in
    When I log in
    Then I should be logged in
