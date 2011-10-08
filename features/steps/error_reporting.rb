Feature "Error reporting" do
  include Integration::SpinachRunner

  Given "I have a feature with some errors" do
    write_file('features/feature_with_errors.feature',
               'Feature: Feature with errors

                Scenario: This scenario will fail
                  Given true is false
                  Then remove all the files in my hard drive
               ')

    write_file('features/steps/error_feature.rb',
               'Feature "Feature with errors" do
                  Given "true is false" do
                    true.must_equal false
                  end

                  Then "remove all the files in my hard drive" do
                    # joking!
                  end
                end')
  end

  When 'I run "spinach"' do
    run_feature 'features/feature_with_errors.feature'
  end

  When 'I run "spinach --backtrace"' do
    run_feature 'features/feature_with_errors.feature', '--backtrace'
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
