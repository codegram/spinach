Feature "Exit status" do
  include Integration::SpinachRunner

  Given "I have a feature that has no error or failure" do
    write_file('features/success_feature.feature',
     'Feature: A success feature

      Scenario: This is scenario will succeed
        Then I succeed
     ')
    write_file('features/steps/success_feature.rb',
    'Feature "A success feature" do
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
    'Feature "A failure feature" do
      Then "I fail" do
        true.must_equal false
      end
     end')
    @feature = "features/failure_feature.feature"
  end

  When "I run it" do
    run_feature @feature
    all_stdout # Hack to get a correct exit status
  end

  Then "the exit status should be 0" do
    last_exit_status.must_equal 0
  end

  Then "the exit status should be 1" do
    last_exit_status.must_equal 1
  end
end
