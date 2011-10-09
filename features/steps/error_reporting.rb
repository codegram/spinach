Feature "Error reporting" do
  include Integration::SpinachRunner

  Given "I have a feature with some failures" do
    write_file('features/feature_with_failures.feature',
               'Feature: Feature with failures

                Scenario: This scenario will fail
                  Given true is false
                  Then remove all the files in my hard drive
               ')

    write_file('features/steps/failure_feature.rb',
               'Feature "Feature with failures" do
                  Given "true is false" do
                    true.must_equal false
                  end

                  Then "remove all the files in my hard drive" do
                    # joking!
                  end
                end')
  end

  When 'I run "spinach"' do
    run_feature 'features/feature_with_failures.feature'
  end

  When 'I run "spinach --backtrace"' do
    run_feature 'features/feature_with_failures.feature', append: '--backtrace'
  end

  Then 'I should see the error count along with their messages' do
    check_error_messages
    all_stderr.wont_match /gems.*minitest.*assert_equal/
  end

  Then 'I should see the error count along with their messages and backtrace' do
    check_error_messages
    check_backtrace
  end

  private
  def check_error_messages
    all_stderr.must_match /Failures \(1\)/
  end

  def check_backtrace
    all_stderr.must_match /Failures \(1\)/
    all_stderr.must_match /gems.*minitest.*assert_equal/
  end
end
