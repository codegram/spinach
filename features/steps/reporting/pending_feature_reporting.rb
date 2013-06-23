class PendingFeatureReporting < Spinach::FeatureSteps

  feature "Pending feature reporting"

  include Integration::SpinachRunner

  Given "I've written a pending scenario" do
    write_file(
      'features/pending_feature.feature',
      """
      Feature: A pending feature

      Scenario: This scenario is pending 
        Given I have a pending step 
      """)

    write_file(
      'features/steps/pending_feature.rb',
      'class APendingFeature < Spinach::FeatureSteps

         feature "A pending feature"

         Given "I have a pending step" do
           pending "This step is pending."
         end
       end')

    @feature = "features/pending_feature.feature"
  end

  Given "I've written a step definition without body" do
    write_file(
      'features/pending_feature.feature',
      """
      Feature: A pending feature

      Scenario: This scenario is pending 
        Given this is also a pending step
      """)

    write_file(
      'features/steps/pending_feature.rb',
      'class APendingFeature < Spinach::FeatureSteps

         feature "A pending feature"

         Given "this is also a pending step"
       end')

    @feature = "features/pending_feature.feature"
  end

  When "I run spinach" do
    run_feature @feature
  end

  Then "I should see a message telling me that there's a pending scenario" do
    @stdout.must_include("(1) Pending")
  end

  And "I should see a message showing me the reason of the pending scenario" do
    @stderr.must_include("This step is pending")
  end

  And "I should see a message showing me the default reason of the pending scenario" do
    @stderr.must_include("step not implemented")
  end

end
