require_relative '../../test_helper'

describe Spinach::Runner::Scenario do
  let(:data) do
    {
      'name' => 'A cool scenario',
      'steps' => [
        {'keyword' => 'Given', 'name' => 'I herd you like steps'},
        {'keyword' => 'When', 'name' => 'I test steps'},
        {'keyword' => 'Then', 'name' => 'I go step by step'}
      ]
    }
  end

  let(:feature) { stub_everything }
  let(:feature_name) { 'My feature' }
  let(:scenario) {
    scenario = Spinach::Runner::Scenario.new(feature_name, data)
    scenario.stubs(feature: feature)
    scenario
  }

  describe '#initialize' do
    it 'lists all the steps' do
      scenario.steps.count.must_equal 3
    end

    it 'sets the feature' do
      scenario.feature.must_equal feature
    end
  end

  describe '#feature' do
    it 'finds the feature given a feature name' do
      scenario.unstub(:feature)
      @feature = stub_everything
      scenario.stubs(feature_name: 'A cool feature')
      Spinach.expects(:find_feature).with('A cool feature').returns(@feature)
      scenario.feature
    end
  end

  describe '#run' do
    it 'calls the appropiate feature steps' do
      feature.expects(:execute_step).with('I herd you like steps')
      feature.expects(:execute_step).with('I test steps')
      feature.expects(:execute_step).with('I go step by step')
      scenario.run
    end

    describe 'when throwing exceptions' do
      it 'rescues a MiniTest::Assertion' do
        feature.expects(:execute_step).raises(MiniTest::Assertion)
        scenario.expects(:run_hook).with(:before_run, has_value("A cool scenario"))
        scenario.expects(:run_hook).with(:after_run, has_value("A cool scenario"))
        scenario.expects(:run_hook).with(
          :on_failed_step, anything, anything, anything)
        scenario.expects(:run_hook).with(
          :on_skipped_step, anything, anything).twice
        scenario.run
      end

      it 'rescues a Spinach::StepNotDefinedException' do
        feature.expects(:execute_step).raises(
          Spinach::StepNotDefinedException.new('bar'))
        scenario.expects(:run_hook).with(:before_run, has_value("A cool scenario"))
        scenario.expects(:run_hook).with(:after_run, has_value("A cool scenario"))
        scenario.expects(:run_hook).with(
          :on_undefined_step, anything, anything, anything)
        scenario.expects(:run_hook).with(
          :on_skipped_step, anything, anything).twice
        scenario.run
      end

      it 'rescues any other error' do
        feature.expects(:execute_step).raises
        scenario.expects(:run_hook).with(:after_run, has_value("A cool scenario"))
        scenario.expects(:run_hook).with(:before_run, has_value("A cool scenario"))
        scenario.expects(:run_hook).with(
          :on_error_step, anything, anything, anything)
        scenario.expects(:run_hook).with(
          :on_skipped_step, anything, anything).twice
        scenario.run
      end

      it 'returns an failure' do
        feature.expects(:execute_step).raises(MiniTest::Assertion)
        scenario.run.wont_equal nil
      end
    end

    it 'runs a step' do
      feature.expects(:execute_step).with(anything).times(3)
      scenario.run.must_equal true
    end

    describe 'hooks' do
      it 'fires up the scenario hooks' do
        feature.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('bar'))
        feature.expects(:run_hook).with(:before_scenario, has_value("A cool scenario"))
        feature.expects(:run_hook).with(:after_scenario, has_value("A cool scenario"))
        scenario.run
      end

      it 'fires up the step hooks' do
        feature.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('bar'))
        %w{before_step after_step}.each do |hook|
          feature.expects(:run_hook).with(
            hook.to_sym, kind_of(Hash))
          feature.expects(:run_hook).with(
            hook.to_sym, kind_of(Hash))
          feature.expects(:run_hook).with(
            hook.to_sym, kind_of(Hash))
        end

        scenario.run
      end
    end
  end
end
