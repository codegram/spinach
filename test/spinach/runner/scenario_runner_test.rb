require_relative '../../test_helper'

module Spinach
  class Runner
    describe ScenarioRunner do
      let(:feature) { stub(name: 'Feature') }
      let(:steps) { [stub(name: 'go shopping'), stub(name: 'do something')] }
      let(:scenario) do
        stub(
          feature: feature,
          steps:   steps
        )
      end

      subject { ScenarioRunner.new(scenario) }

      describe 'delegations' do
        it 'delegates #feature to the scenario' do
          subject.feature.must_equal feature
        end

        it 'delegates #steps to the scenario' do
          subject.steps.must_equal steps
        end
      end

      describe '#step_definitions' do
        it 'looks up the step definitions' do
          klass = Class.new
          Spinach.expects(:find_step_definitions).with('Feature').returns klass
          subject.step_definitions
        end
      end

      describe '#run' do
        describe 'hooks' do
          it 'runs hooks in order' do
            hooks = sequence('hooks')
            subject.stubs(:step_definitions).returns step_definitions = stub

            Spinach.hooks.expects(:run_before_scenario).with(scenario).in_sequence(hooks)

            Spinach.hooks.expects(:run_before_step).with(steps.first).in_sequence(hooks)
            subject.expects(:run_step).with(steps.first)
            Spinach.hooks.expects(:run_after_step).with(steps.first).in_sequence(hooks)

            Spinach.hooks.expects(:run_before_step).with(steps.last).in_sequence(hooks)
            subject.expects(:run_step).with(steps.last)
            Spinach.hooks.expects(:run_after_step).with(steps.last).in_sequence(hooks)

            Spinach.hooks.expects(:run_after_scenario).with(scenario).in_sequence(hooks)

            subject.run
          end
        end
      end

      # describe '#run'


      # describe '#initialize' do
      #   it 'lists all the steps' do
      #     subject.steps.count.must_equal 3
      #   end

      #   it 'sets the feature' do
      #     subject.feature_steps.must_equal feature_steps
      #   end
      # end

      # describe '#feature' do
      #   it 'finds the feature given a feature name' do
      #     subject.unstub(:feature_steps)
      #     @feature = stub_everything
      #     subject.stubs(feature_name: 'A cool feature')
      #     Spinach.expects(:find_step_definitions).with('A cool feature').returns(@feature)
      #     subject.feature_steps
      #   end
      # end

      # describe '#run' do
      #   it 'calls the appropiate feature steps' do
      #     feature_steps.expects(:execute_step).with('I herd you like steps')
      #     feature_steps.expects(:execute_step).with('I test steps')
      #     feature_steps.expects(:execute_step).with('I go step by step')
      #     subject.run
      #   end

      #   describe 'when throwing exceptions' do
      #     it 'rescues a MiniTest::Assertion' do
      #       Spinach.config[:failure_exceptions] << MiniTest::Assertion
      #       feature_steps.expects(:execute_step).raises(MiniTest::Assertion)
      #       Spinach.hooks.expects("run_before_scenario").with(has_value("A cool scenario"))
      #       Spinach.hooks.expects("run_after_scenario").with(has_value("A cool scenario"))
      #       Spinach.hooks.expects('run_on_failed_step').with(anything, anything, anything)
      #       Spinach.hooks.expects('run_on_skipped_step').with(anything, anything).twice
      #       subject.run
      #     end

      #     it 'rescues a Spinach::StepNotDefinedException' do
      #       feature_steps.expects(:execute_step).raises(
      #         Spinach::StepNotDefinedException.new('bar'))
      #       Spinach.hooks.expects("run_before_scenario").with(has_value("A cool scenario"))
      #       Spinach.hooks.expects("run_after_scenario").with(has_value("A cool scenario"))
      #       Spinach.hooks.expects("run_on_undefined_step").with(
      #         anything, anything, anything)
      #       Spinach.hooks.expects("run_on_skipped_step").with(
      #         anything, anything).twice
      #       subject.run
      #     end

      #     it 'rescues any other error' do
      #       feature_steps.expects(:execute_step).raises
      #       Spinach.hooks.expects("run_after_scenario").with(has_value("A cool scenario"))
      #       Spinach.hooks.expects("run_before_scenario").with(has_value("A cool scenario"))
      #       Spinach.hooks.expects("run_on_error_step").with(anything, anything, anything)
      #       Spinach.hooks.expects("run_on_skipped_step").with(anything, anything).twice
      #       subject.run
      #     end

      #     it 'returns an failure' do
      #       feature_steps.expects(:execute_step).raises(MiniTest::Assertion)
      #       subject.run.wont_equal nil
      #     end
      #   end

      #   it 'runs a step' do
      #     feature_steps.expects(:execute_step).with(anything).times(3)
      #     subject.run.must_equal true
      #   end

      #   describe 'hooks' do
      #     it 'fires up the scenario hooks' do
      #       feature_steps.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('bar'))
      #       Spinach.hooks.expects(:run_before_scenario).with(has_value("A cool scenario"))
      #       Spinach.hooks.expects(:run_after_scenario).with(has_value("A cool scenario"))
      #       subject.run
      #     end

      #     it 'fires up the step hooks' do
      #       feature_steps.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('bar'))
      #       %w{before_step after_step}.each do |hook|
      #         Spinach.hooks.expects("run_#{hook}").with(kind_of(Hash)).times(3)
      #       end

      #       subject.run
      #     end
      #   end
      # end
    end

  end
end
