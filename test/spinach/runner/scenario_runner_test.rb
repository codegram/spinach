require_relative '../../test_helper'

describe Spinach::Runner::ScenarioRunner do
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

  let(:feature_steps) { stub_everything }
  let(:feature_name) { 'My feature' }
  subject{
    scenario = Spinach::Runner::ScenarioRunner.new(feature_name, data)
    scenario.stubs(feature_steps: feature_steps)
    scenario
  }

  describe '#initialize' do
    it 'lists all the steps' do
      subject.steps.count.must_equal 3
    end

    it 'sets the feature' do
      subject.feature_steps.must_equal feature_steps
    end
  end

  describe '#feature' do
    it 'finds the feature given a feature name' do
      subject.unstub(:feature_steps)
      @feature = stub_everything
      subject.stubs(feature_name: 'A cool feature')
      Spinach.expects(:find_feature_steps).with('A cool feature').returns(@feature)
      subject.feature_steps
    end
  end

  describe '#run' do
    it 'calls the appropiate feature steps' do
      feature_steps.expects(:execute_step).with('I herd you like steps')
      feature_steps.expects(:execute_step).with('I test steps')
      feature_steps.expects(:execute_step).with('I go step by step')
      subject.run
    end

    describe 'when throwing exceptions' do
      it 'rescues a MiniTest::Assertion' do
        feature_steps.expects(:execute_step).raises(MiniTest::Assertion)
        Spinach.hooks.expects("run_before_scenario").with(has_value("A cool scenario"))
        Spinach.hooks.expects("run_after_scenario").with(has_value("A cool scenario"))
        Spinach.hooks.expects('run_on_failed_step').with(anything, anything, anything)
        Spinach.hooks.expects('run_on_skipped_step').with(anything, anything).twice
        subject.run
      end

      it 'rescues a Spinach::StepNotDefinedException' do
        feature_steps.expects(:execute_step).raises(
          Spinach::StepNotDefinedException.new('bar'))
        Spinach.hooks.expects("run_before_scenario").with(has_value("A cool scenario"))
        Spinach.hooks.expects("run_after_scenario").with(has_value("A cool scenario"))
        Spinach.hooks.expects("run_on_undefined_step").with(
          anything, anything, anything)
        Spinach.hooks.expects("run_on_skipped_step").with(
          anything, anything).twice
        subject.run
      end

      it 'rescues any other error' do
        feature_steps.expects(:execute_step).raises
        Spinach.hooks.expects("run_after_scenario").with(has_value("A cool scenario"))
        Spinach.hooks.expects("run_before_scenario").with(has_value("A cool scenario"))
        Spinach.hooks.expects("run_on_error_step").with(anything, anything, anything)
        Spinach.hooks.expects("run_on_skipped_step").with(anything, anything).twice
        subject.run
      end

      it 'returns an failure' do
        feature_steps.expects(:execute_step).raises(MiniTest::Assertion)
        subject.run.wont_equal nil
      end
    end

    it 'runs a step' do
      feature_steps.expects(:execute_step).with(anything).times(3)
      subject.run.must_equal true
    end

    describe 'hooks' do
      it 'fires up the scenario hooks' do
        feature_steps.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('bar'))
        Spinach.hooks.expects(:run_before_scenario).with(has_value("A cool scenario"))
        Spinach.hooks.expects(:run_after_scenario).with(has_value("A cool scenario"))
        subject.run
      end

      it 'fires up the step hooks' do
        feature_steps.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('bar'))
        %w{before_step after_step}.each do |hook|
          Spinach.hooks.expects("run_#{hook}").with(kind_of(Hash)).times(3)
        end

        subject.run
      end
    end
  end
end
