class ShowStepSourceLocation < Spinach::FeatureSteps

  feature "Show step source location"

  include Integration::SpinachRunner

  Given "I have a feature that has no error or failure" do
    write_file('features/success_feature.feature', """
Feature: A success feature

  Scenario: This is scenario will succeed
    Then I succeed
""")

    write_file('features/steps/success_feature.rb',
    'class ASuccessFeature < Spinach::FeatureSteps
      feature "A success feature"
      Then "I succeed" do
      end
     end')
    @feature = "features/success_feature.feature"
  end

  When "I run it" do
    run_feature @feature
  end

  Then "I should see the source location of each step of every scenario" do
    @stdout.must_match(
      /I succeed.*features\/steps\/success_feature\.rb.*3/
    )
  end

  Given "I have a feature that has no error or failure and use external steps" do
    write_file('features/success_feature.feature', """
Feature: A feature that uses external steps

  Scenario: This is scenario will succeed
    Given this is a external step
""")

    write_file('features/steps/success_feature.rb',
    'class AFeatureThatUsesExternalSteps < Spinach::FeatureSteps
      feature "A feature that uses external steps"
      include ExternalSteps
     end')
    write_file('features/support/external_steps.rb',
    'module ExternalSteps
      include Spinach::DSL
      Given "this is a external step" do
      end
    end')
    @feature = "features/success_feature.feature"
  end

  Then "I should see the source location of each step, even external ones" do
    @stdout.must_match(
      /this is a external step.*features\/support\/external_steps\.rb.*3/
    )
  end

  Given "I have a feature that has an error" do
    write_file('features/error_feature.feature', """
Feature: An error feature

  Scenario: This is scenario will not succeed
    Then I do not succeed
""")

    write_file('features/steps/error_feature.rb',
    'class AnErrorFeature < Spinach::FeatureSteps
      feature "An error feature"
      Then "I do not succeed" do
        i_do_not_exist.must_be_equal "Your Mumma"
      end
     end')
    @feature = "features/error_feature.feature"
  end

  Then "I should see the source location of each step, even ones with errors" do
    @stdout.must_match(
      /I do not succeed.*features\/steps\/error_feature\.rb.*3/
    )
  end

  Given "I have a feature that has a failure" do
    write_file('features/failure_feature.feature', """
Feature: A failure feature

  Scenario: This is scenario will not succeed
    Then I do not succeed
""")

    write_file('features/steps/failure_feature.rb',
    'class AFailureFeature < Spinach::FeatureSteps
      feature "A failure feature"
      Then "I do not succeed" do
        i_exist = "Your Pappa"
        i_exist.must_be_equal "Your Mumma"
      end
     end')
    @feature = "features/failure_feature.feature"
  end

  Then "I should see the source location of each step, even ones with failures" do
    @stdout.must_match(
      /I do not succeed.*features\/steps\/failure_feature\.rb.*3/
    )
  end
end
