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
    run_feature 'features/cheezburger_can_i_has.feature', append: '--audit'
  end

  step 'I should see a list of unused steps' do
    @stdout.must_match(/Unused step: .*cheezburger_can_i_has.rb:6 'I get some roxxorz'/)
  end

  step 'I should see the code to paste for missing steps' do
    @stdout.must_match("step 'I get some lulz' do")
    @stdout.must_match("step 'I cannot haz' do")
  end

  step 'I have an associated step file with some steps in a common module' do
    write_file('features/steps/cheezburger_can_i_has.rb', """
class Spinach::Features::CheezburgerCanIHaz < Spinach::FeatureSteps
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
  step 'I haz a sad' do
    pending 'step not implemented'
  end
  step 'I haz a happy' do
    pending 'step not implemented'
  end
end
""")
  end

  step 'I should not see the common steps marked as missing' do
    @stdout.wont_match("step 'I haz a sad' do")
    @stdout.wont_match("step 'I haz a happy' do")
  end
  
  step 'Deary me' do
    puts "Oh dear"
  end
  
end
