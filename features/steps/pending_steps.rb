class Spinach::Features::PendingSteps < Spinach::FeatureSteps
  include Integration::SpinachRunner

  step 'I have a feature that has a pending step' do
    @feature = Integration::FeatureGenerator.pending_feature
  end

  step 'I run the feature' do
    run_feature @feature
  end

  step 'the test stops at the pending step and reported as such' do
    @stdout.must_match("(0) Successful")
  end
end
