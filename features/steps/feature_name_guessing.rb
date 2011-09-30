require 'aruba/api'

Feature "Feature name guessing" do
  include Aruba::Api

  Given 'I am writing a feature called "My cool feature"' do
    write_file('features/my_cool_feature.feature',
               'Feature: My cool feature

                Scenario: This is scenario is cool
                  When this is so meta
                  Then the world is crazy
               ')
  end

  And 'I write a class named "MyCoolFeature"' do
    write_file('features/steps/my_cool_feature.rb',
               'Feature "My cool feature" do
                  When "this is so meta" do
                  end

                  Then "the world is crazy" do
                  end
                end')
  end

  When 'I run spinach'do
    run_feature 'features/my_cool_feature.feature'
  end

  Then 'I want "MyCoolFeature" class to be used to run it' do
    all_stderr.must_be_empty
  end

  private

  def run_feature(command)
    run "../../bin/spinach #{command}"
  end
end
