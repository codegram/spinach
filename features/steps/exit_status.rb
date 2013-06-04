class ExitStatus < Spinach::FeatureSteps

  feature "Exit status"

  include Integration::SpinachRunner

  Given "I have a feature that has no error or failure" do
    @feature = Integration::FeatureGenerator.success_feature
  end

  Given "I have a feature that has a failure" do
    @feature = Integration::FeatureGenerator.failure_feature
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
