class UndefinedFeatureReporting < Spinach::FeatureSteps

  feature "Undefined feature reporting"

  include Integration::SpinachRunner

  Given "I've written a feature but not its steps" do
    write_file('features/feature_without_steps.feature', """
Feature: Feature without steps

  Scenario: A scenario without steps
    Given I have no steps
    Then I should do nothing
""")
  end

  When "I run spinach" do
    run_feature 'features/feature_without_steps.feature'
  end

  Then "I should see a message telling me that there's an undefined feature" do
    @stderr.must_match /Undefined features.*1/
  end
end
