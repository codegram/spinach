class RSpecCompatibility < Spinach::FeatureSteps

  feature "RSpec compatibility"

  include Integration::SpinachRunner
  include Integration::ErrorReporting

  Given 'I have a feature that should completely pass' do
    write_file('features/feature_without_failures.feature', """
Feature: Feature without failures

  Scenario: This scenario will pass
    Then RSpec expectations and matchers are available
""")

    write_file('features/steps/rspec_feature.rb',
               'class FeatureWithoutFailures < Spinach::FeatureSteps
                  feature "Feature without failures"
                  Then "RSpec expectations and matchers are available" do
                    42.0.should be_within(0.2).of(42.1)
                  end
                end')
    @feature = 'feature_without_failures'
  end

  Given "I have a feature with some failed expectations" do
    write_file('features/feature_with_failures.feature', """
Feature: Feature with failures in RSpec compatibility test

  Scenario: This scenario will fail
    Given true is false
    Then remove all the files in my hard drive""")

    write_file('features/steps/failure_feature.rb',
               'class FeatureWithFailures < Spinach::FeatureSteps
                  feature "Feature with failures in RSpec compatibility test"
                  Given "true is false" do
                    true.should == false
                  end

                  Then "remove all the files in my hard drive" do
                    # joking!
                  end
                end')
    @feature = 'feature_with_failures'
  end

  When "I run \"spinach\" with rspec" do
    @feature =
      run_feature "features/#{@feature}.feature", framework: :rspec
  end

  Then "I should see the failure count along with their messages" do
    check_error_messages(1)
  end

  Given  'I have a sinatra app with some capybara-based expectations' do
    write_file("features/support/app.rb", '
      require "sinatra"
      require "spinach/capybara"
      app = Sinatra::Application.new do
        get "/" do
          \'Hello world!\'
        end
      end
      Capybara.app = app
    ')

    write_file('features/greeting.feature', """
Feature: Greeting

  Scenario: Greeting
    Given I am on the front page
    Then I should see hello world
""")

    write_file('features/steps/greeting.rb',
               'require "spinach/capybara"
                class Greeting < Spinach::FeatureSteps
                  Given "I am on the front page" do
                    visit "/"
                  end

                  Then "I should see hello world" do
                    page.should have_content("Hello world")
                  end
                end')
    @feature = 'greeting'
  end

  Given  'There should be no error' do
    @last_exit_status.must_equal 0
  end

end
