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

      describe '#run_step' do
        before do
          @step             = stub(name: 'Go shopping')
          @step_definitions = stub
          @step_definitions.stubs(:step_location_for).with('Go shopping').returns @location = stub
          subject.stubs(:step_definitions).returns @step_definitions
        end

        describe 'when the step is successful' do
          it 'runs the successful hooks' do
            @step_definitions.stubs(:execute).with(@step).returns true
            Spinach.hooks.expects(:run_on_successful_step).with(@step, @location)

            subject.run_step(@step)
          end
        end

        describe 'when the step fails' do
          before do
            @failure_exception = Class.new(StandardError)
            Spinach.stubs(:config).returns({ failure_exceptions: [@failure_exception] })
            @step_definitions.stubs(:execute).with(@step).raises @failure_exception
          end

          it 'sets the exception' do
            subject.run_step(@step)
            subject.instance_variable_get(:@exception).must_be_kind_of(@failure_exception)
          end

          it 'runs the failed hooks' do
            Spinach.hooks.expects(:run_on_failed_step).with(@step, kind_of(@failure_exception), @location)
            subject.run_step(@step)
          end
        end

        describe 'when the step is undefined' do
          before do
            @step_definitions.stubs(:execute).with(@step).raises Spinach::StepNotDefinedException, @step
          end

          it 'sets the exception' do
            subject.run_step(@step)
            subject.instance_variable_get(:@exception).must_be_kind_of(Spinach::StepNotDefinedException)
          end

          it 'runs the undefined hooks' do
            Spinach.hooks.expects(:run_on_undefined_step).with(@step, kind_of(Spinach::StepNotDefinedException))
            subject.run_step(@step)
          end
        end

        describe 'when the step raises an error' do
          before do
            @step_definitions.stubs(:execute).with(@step).raises StandardError
          end

          it 'sets the exception' do
            subject.run_step(@step)
            subject.instance_variable_get(:@exception).must_be_kind_of(StandardError)
          end

          it 'runs the error hooks' do
            Spinach.hooks.expects(:run_on_error_step).with(@step, kind_of(StandardError), @location)
            subject.run_step(@step)
          end
        end
      end
    end
  end
end
