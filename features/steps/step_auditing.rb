class Spinach::Features::StepAuditing < Spinach::FeatureSteps
  
  include Integration::SpinachRunner
  step 'I have defined a "Cheezburger can I has" feature' do
    write_file('features/cheezburger_can_i_has.feature', """
Feature: Cheezburger can I has
  Scenario: Some Lulz
    Given I haz a sad
    When I get some lulz
    Then I haz a happy
  Scenario: Cannot haz
    Given I wantz cheezburger
    When I ask can haz
    Then I cannot haz
""")
  end
  
  step 'I have an associated step file with missing steps and obsolete steps' do
    write_file('features/steps/cheezburger_can_i_has.rb', """
class Spinach::Features::CheezburgerCanIHas < Spinach::FeatureSteps
  step 'I haz a sad' do
    pending 'step not implemented'
  end
  step 'I get some roxxorz' do
    pending 'step not implemented'
  end
  step 'I haz a happy' do
    pending 'step not implemented'
  end
  step 'I ask can haz' do
    pending 'step not implemented'
  end
end
""")    
  end

  step 'I run spinach with "--audit"' do
    run_feature 'features', append: '--audit'
  end

  step 'I should see a list of unused steps' do
    @stdout.must_match(/Unused step: .*cheezburger_can_i_has.rb:6 'I get some roxxorz'/)
  end

  step 'I should see the code to paste for missing steps' do
    @stdout.must_match("Missing steps")
    @stdout.must_match("step 'I get some lulz' do")
    @stdout.must_match("step 'I cannot haz' do")
  end

  step 'I have an associated step file with some steps in a common module' do
    write_file('features/steps/cheezburger_can_i_has.rb', """
class Spinach::Features::CheezburgerCanIHas < Spinach::FeatureSteps
  include HappySad
  step 'I get some roxxorz' do
    pending 'step not implemented'
  end
  step 'I ask can haz' do
    pending 'step not implemented'
  end
end
""")
    write_file('features/steps/happy_sad.rb', """
module HappySad
  include Spinach::DSL
  step 'I haz a sad' do
    pending 'step not implemented'
  end
  step 'I haz a happy' do
    pending 'step not implemented'
  end
end
""")
  end

  step 'I should not see any steps marked as missing' do
    @stdout.wont_match("Missing steps")
  end
  
  step 'I should not see any steps marked as unused' do
    @stdout.wont_match("Unused step")
  end
  
  step 'I have defined an "Awesome new feature" feature' do
    write_file('features/awesome_new_feature.feature', """
  Feature: Awesome new feature
    Scenario: Awesomeness
      Given I am awesome
      When I do anything
      Then people will cheer
  """)
  end

  step 'I have associated step files with common steps that are all used somewhere' do
    write_file('features/steps/cheezburger_can_i_has.rb', """
  class Spinach::Features::CheezburgerCanIHas < Spinach::FeatureSteps
    include Awesome
    step 'I haz a sad' do
      pending 'step not implemented'
    end
    step 'I get some lulz' do
      pending 'step not implemented'
    end
    step 'I wantz cheezburger' do
      pending 'step not implemented'
    end
    step 'I ask can haz' do
      pending 'step not implemented'
    end
    step 'I cannot haz' do
      pending 'step not implemented'
    end
  end
  """)
    write_file('features/steps/awesome_new_feature.rb', """
  class Spinach::Features::AwesomeNewFeature < Spinach::FeatureSteps
    include Awesome
    step 'I do anything' do
      pending 'step not implemented'
    end
  end
  """)
    write_file('features/steps/awesome.rb', """
  module Awesome
    include Spinach::DSL
    step 'I am awesome' do
      pending 'step not implemented'
    end
    step 'people will cheer' do
      pending 'step not implemented'
    end
    step 'I haz a happy' do
      pending 'step not implemented'
    end
  end
  """)
  end

  step 'I have not created an associated step file' do
    # Do nothing
  end

  step 'I should be told to run "--generate"' do
    @stdout.must_match("Step file missing: please run --generate first!")
  end

  step 'I have created a step file for each with a step from one feature pasted into the other\'s file' do    
    write_file('features/steps/cheezburger_can_i_has.rb', """
class Spinach::Features::CheezburgerCanIHas < Spinach::FeatureSteps
  step 'I haz a sad' do
    pending 'step not implemented'
  end
  step 'I get some lulz' do
    pending 'step not implemented'
  end
  step 'I haz a happy' do
    pending 'step not implemented'
  end
  step 'I wantz cheezburger' do
    pending 'step not implemented'
  end
  step 'I ask can haz' do
    pending 'step not implemented'
  end
  step 'I cannot haz' do
    pending 'step not implemented'
  end
end
""")
    write_file('features/steps/awesome_new_feature.rb', """
class Spinach::Features::AwesomeNewFeature < Spinach::FeatureSteps
  step 'I am awesome' do
    pending 'step not implemented'
  end
  step 'I do anything' do
    pending 'step not implemented'
  end
  step 'people will cheer' do
    pending 'step not implemented'
  end
  step 'I haz a happy' do
    pending 'step not implemented'
  end
end
""")
  end

  step 'I should be told that step is unused' do
    @stdout.must_match(/Unused step: .*awesome_new_feature.rb:12 'I haz a happy'/)
  end

  step 'I have complete step files for both' do
    write_file('features/steps/cheezburger_can_i_has.rb', """
class Spinach::Features::CheezburgerCanIHas < Spinach::FeatureSteps
  step 'I haz a sad' do
    pending 'step not implemented'
  end
  step 'I get some lulz' do
    pending 'step not implemented'
  end
  step 'I haz a happy' do
    pending 'step not implemented'
  end
  step 'I wantz cheezburger' do
    pending 'step not implemented'
  end
  step 'I ask can haz' do
    pending 'step not implemented'
  end
  step 'I cannot haz' do
    pending 'step not implemented'
  end
end
""")
    write_file('features/steps/awesome_new_feature.rb', """
class Spinach::Features::AwesomeNewFeature < Spinach::FeatureSteps
  step 'I am awesome' do
    pending 'step not implemented'
  end
  step 'I do anything' do
    pending 'step not implemented'
  end
  step 'people will cheer' do
    pending 'step not implemented'
  end
end
""")
  end

  step 'I should be told this was a clean audit' do
    @stdout.must_match('Audit clean - no missing steps.')
  end

  step 'I have defined an "Exciting feature" feature with reused steps' do
    write_file('features/exciting_feature.feature', """
Feature: Exciting feature
  Scenario: One
    Given I exist
    When I do nothing
    Then I should still exist
  Scenario: Two
    Given I exist
    When I jump up and down
    Then I should still exist
""")
  end

  step 'I have created a step file without those reused steps' do
    write_file('features/steps/exciting_feature.rb', """
class Spinach::Features::ExcitingFeature < Spinach::FeatureSteps
  step 'I do nothing' do
    pending 'step not implemented'
  end
end
""")
  end

  step 'I should see the missing steps reported only once' do
    @stdout.scan('I exist').count.must_equal 1
    @stdout.scan('I should still exist').count.must_equal 1
  end
  
  step 'I have step files for both with common steps, but one common step is not used by either' do
    write_file('features/steps/cheezburger_can_i_has.rb', """
class Spinach::Features::CheezburgerCanIHas < Spinach::FeatureSteps
  include Awesome
  step 'I haz a sad' do
    pending 'step not implemented'
  end
  step 'I get some lulz' do
    pending 'step not implemented'
  end
  step 'I wantz cheezburger' do
    pending 'step not implemented'
  end
  step 'I ask can haz' do
    pending 'step not implemented'
  end
  step 'I cannot haz' do
    pending 'step not implemented'
  end
end
""")
    write_file('features/steps/awesome_new_feature.rb', """
class Spinach::Features::AwesomeNewFeature < Spinach::FeatureSteps
  include Awesome
  step 'I am awesome' do
    pending 'step not implemented'
  end
  step 'people will cheer' do
    pending 'step not implemented';
  end
end
""")
    write_file('features/steps/awesome.rb', """
module Awesome
  include Spinach::DSL
  step 'I do anything' do
    pending 'step not implemented'
  end
  step 'I haz a happy' do
    pending 'step not implemented'
  end
  step 'I enter the void' do
    pending 'step not implemented'
  end
end
""")
  end

  step 'I should be told the extra step is unused' do
    @stdout.must_match(/Unused step: .*awesome.rb:10 'I enter the void'/)
  end

  step 'I should not be told the other common steps are unused' do
    @stdout.wont_match('I do anything')
    @stdout.wont_match('I haz a happy')
  end
  
  step 'bad' do
    pending 'hello'
  end
  
end
