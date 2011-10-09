Feature "RSpec compatibility" do
  include Integration::SpinachRunner
  include Integration::ErrorReporting

  Given "I have a feature with some failed expectations" do
    write_file('features/feature_with_failures.feature',
               'Feature: Feature with failures

                Scenario: This scenario will fail
                  Given true is false
                  Then remove all the files in my hard drive
               ')

    write_file('features/steps/failure_feature.rb',
               'Feature "Feature with failures" do
                  Given "true is false" do
                    true.should == false
                  end

                  Then "remove all the files in my hard drive" do
                    # joking!
                  end
                end')
  end
  When "I run \"spinach\" with rspec" do
    run_feature 'features/feature_with_failures.feature', suite: :rspec
  end
  Then "I should see the failure count along with their messages" do
    check_error_messages(1)
  end
end
