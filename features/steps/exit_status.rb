class ExitStatus < Spinach::FeatureSteps

  feature "Exit status"

  include Integration::SpinachRunner

  Given "I have a feature that has no error or failure" do
    write_file('features/success_feature.feature',
     'Feature: A success feature

      Scenario: This is scenario will succeed
        Then I succeed
     ')
    write_file('features/steps/success_feature.rb',
    'class ASuccessFeature < Spinach::FeatureSteps
      feature "A success feature"
      Then "I succeed" do
      end
     end')
    @feature = "features/success_feature.feature"
  end

  Given "I have a feature that has a failure" do
    write_file('features/failure_feature.feature',
     'Feature: A failure feature

      Scenario: This is scenario will fail
        Then I fail
     ')
    write_file('features/steps/failure_feature.rb',
    'class AFailureFeature < Spinach::FeatureSteps
      feature "A failure feature"
      Then "I fail" do
        true.must_equal false
      end
     end')
    @feature = "features/failure_feature.feature"
  end

  When "I run it" do
    run_feature @feature
  end

  Then "the exit status should be 0" do
    @last_exit_status.must_equal 0
  end

  Then "the exit status should be 1" do
    @last_exit_status.must_equal 1
  end
end
