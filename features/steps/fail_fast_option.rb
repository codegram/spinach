class Spinach::Features::FailFastOption < Spinach::FeatureSteps
  include Integration::SpinachRunner

  step 'I have a feature that has a failure' do
    @features ||= []
    @features << Integration::FeatureGenerator.failure_feature_with_two_scenarios
  end

  step 'I have a feature that has no error or failure' do
    @features ||= []
    @features << Integration::FeatureGenerator.success_feature
  end

  step 'I run both of them with fail-fast option' do
    run_feature @features.join(" "), append: '--fail-fast'
  end

  step 'the tests stop at the first one' do
    @stdout.must_match("(0) Successful")
  end
end
