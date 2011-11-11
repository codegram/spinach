class AutomaticFeatureGeneration < Spinach::FeatureSteps

  feature 'Automatic feature generation'

  include Integration::SpinachRunner
  Given 'I have defined a "Cheezburger can I has" feature' do
    write_file('features/cheezburger_can_i_has.feature', """
Feature: Cheezburger can I has
  Scenario: Some Lulz
    Given I haz a sad
    When I get some lulz
    Then I haz a happy
""")
  end

  When 'I run spinach with "--generate"' do
    run_feature 'features/cheezburger_can_i_has.feature', append: '--generate'
  end

  Then 'I a feature should exist named "features/steps/cheezburger_can_i_has.rb"' do
    in_current_dir do
      @file = 'features/steps/cheezburger_can_i_has.rb'
      File.exists?(@file).must_equal true
    end
  end

  And "that feature should have the example feature steps" do
    in_current_dir do
      content = File.read(@file)
      content.must_include "I haz a sad"
      content.must_include "I get some lulz"
      content.must_include "I haz a happy"
    end
  end
end
