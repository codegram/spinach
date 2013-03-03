# encoding: utf-8

class DisplayRunSummary < Spinach::FeatureSteps

  feature 'automatic'

  include Integration::SpinachRunner

  Given "I have a feature that has some successful, undefined, failed and error steps" do
    write_file('features/test_feature.feature', """

Feature: A test feature

  Scenario: Undefined scenario
    Given I am a fool
    When I jump from Codegrams roof
    Then I must be pwned by floor

  Scenario: Failed scenario
    Given I love risk
    When I jump from Codegrams roof
    Then my parachute must open
    Then I must not be pwned by floor

  Scenario: Error scenario
    Given I am not a fool
    When I go downstairs
    Then I must succeed
""")

    write_file('features/steps/test_feature.rb',
    'class ATestFeature < Spinach::FeatureSteps
      feature "A test feature"

      Given "I am a fool" do
      end

      When "I jump from Codegrams roof" do
      end

      Given "I love risk" do
      end

      And "my parachute must open" do
        false.must_equal true
      end

      Given "I am a fool" do
      end

      Given "I am not a fool" do
        adaksjdald
      end

      When "I go downstairs" do
      end

      Then "I must succeed" do
        true
      end
     end')
    @feature = "features/test_feature.feature"
  end

  When "I run it" do
    run_feature @feature
  end

  Then "I should see a summary with steps status information" do
    @stdout.must_match(
      /Summary:.*4.*Successful.*1.*Undefined.*1.*Failed.*1.*Error/
    )
  end
end
