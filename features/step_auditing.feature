Feature: Step auditing
  In order to be able to update my features
  As a developer
  I want spinach to automatically audit which steps are missing and obsolete
  
  Scenario: Step file out of date
    Given I have defined a "Cheezburger can I has" feature
    And I have an associated step file with missing steps and obsolete steps
    When I run spinach with "--audit"
    Then I should see a list of obsolete steps
    And I should see the code to paste for missing steps
    
  Scenario: With common steps
    Given I have defined a "Cheezburger can I has" feature
    And I have an associated step file with some steps in a common module
    When I run spinach with "--audit"
    Then I should not see the common steps marked as missing
  
    
