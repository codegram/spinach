class Background < Spinach::FeatureSteps

  feature 'Background'

  def initialize
    @background_step = false
    @scenario_step   = false
  end

  And 'another step in this scenario' do
    @scenario_step = true
  end

  When 'I run this Scenario' do
    # Nothing to be done.
  end

  Then 'the background step should have been executed' do
    @background_step.must_equal true
  end

  Then 'the scenario step should have been executed' do
    @scenario_step.must_equal true
  end

  Given 'Spinach has Background support' do
    @background_step = true
  end

end
