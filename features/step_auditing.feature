Feature: Step auditing
  In order to be able to update my features
  As a developer
  I want spinach to automatically audit which steps are missing and obsolete
  
  Scenario: Step file out of date
    Given I have defined a "Cheezburger can I has" feature
    And I have an associated step file with missing steps and obsolete steps
    When I run spinach with "--audit"
    Then I should see a list of unused steps
    And I should see the code to paste for missing steps
    
  Scenario: With common steps
    Given I have defined a "Cheezburger can I has" feature
    And I have an associated step file with some steps in a common module
    When I run spinach with "--audit"
    Then I should not see any steps marked as missing
  
  Scenario: Steps not marked unused if they're in common modules
    Given I have defined a "Cheezburger can I has" feature
    And I have defined an "Awesome new feature" feature
    And I have associated step files with common steps that are all used somewhere
    When I run spinach with "--audit"
    Then I should not see any steps marked as unused
    
  Scenario: Common steps are reported as missing if not used by any feature
    Given I have defined a "Cheezburger can I has" feature
    And I have defined an "Awesome new feature" feature
    And I have step files for both with common steps, but one common step is not used by either
    When I run spinach with "--audit"
    Then I should be told the extra step is unused
    But I should not be told the other common steps are unused
    
  Scenario: Tells the user to generate if step file missing
    Given I have defined a "Cheezburger can I has" feature
    And I have not created an associated step file
    When I run spinach with "--audit"
    Then I should be told to run "--generate"
  
  Scenario: Steps still marked unused if they appear in the wrong file
    Given I have defined a "Cheezburger can I has" feature
    And I have defined an "Awesome new feature" feature
    And I have created a step file for each with a step from one feature pasted into the other's file
    When I run spinach with "--audit"
    Then I should be told that step is unused
  
  Scenario: Reports a clean audit if no steps are missing
    Given I have defined a "Cheezburger can I has" feature
    And I have defined an "Awesome new feature" feature
    And I have complete step files for both
    When I run spinach with "--audit"
    Then I should be told this was a clean audit

  Scenario: Should not report a step as missing more than once
    Given I have defined an "Exciting feature" feature with reused steps
    And I have created a step file without those reused steps
    When I run spinach with "--audit"
    Then I should see the missing steps reported only once
    
