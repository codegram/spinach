require_relative '../../test_helper'

module Spinach
  class Runner
    describe ScenarioRunner do
      let(:feature) { stub(name: 'Feature', background_steps: []) }
      let(:steps) { [
        stub(name: 'go shopping', keyword: "key"), stub(name: 'do something', keyword: "key2")
      ] }
      let(:scenario) do
        stub(
          feature: feature,
          steps:   steps,
          name:    "scenario name"
        )
      end

      subject { ScenarioRunner.new(scenario) }
      let(:step_definitions){ subject.step_definitions }

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
        describe 'hooks (no #run_step stub)' do
          before(:each) do
            subject.stubs(:step_definitions).returns step_definitions = stub
            step_definitions.stubs(:before_each)
            step_definitions.stubs(:after_each)
            step_definitions.stubs(:step_location_for)
          end

          let(:scenario) { stub(feature: feature, steps: [steps.first], name: 'test' ) }

          it 'runs hooks in order (no #run_step stub)' do
            hooks = sequence('hooks')

            Spinach.hooks.expects(:run_before_scenario).with(scenario, step_definitions).in_sequence(hooks)
            Spinach.hooks.expects(:run_around_scenario).with(scenario, step_definitions).in_sequence(hooks).yields

            Spinach.hooks.expects(:run_before_step).with(steps.first, step_definitions).in_sequence(hooks)
            Spinach.hooks.expects(:run_around_step).with(steps.first, step_definitions).in_sequence(hooks).yields
            Spinach.hooks.expects(:run_after_step).with(steps.first, step_definitions).in_sequence(hooks)

            Spinach.hooks.expects(:run_after_scenario).with(scenario, step_definitions).in_sequence(hooks)
            subject.run
          end
        end

        describe 'hooks' do
          before(:each) do
            subject.stubs(:step_definitions).returns step_definitions = stub
            step_definitions.stubs(:before_each)
            step_definitions.stubs(:after_each)
          end

          it 'runs hooks in order' do
            hooks = sequence('hooks')

            Spinach.hooks.expects(:run_before_scenario).with(scenario, step_definitions).in_sequence(hooks)
            Spinach.hooks.expects(:run_around_scenario).with(scenario, step_definitions).in_sequence(hooks).yields

            Spinach.hooks.expects(:run_before_step).with(steps.first, step_definitions).in_sequence(hooks)
            subject.expects(:run_step).with(steps.first)
            Spinach.hooks.expects(:run_after_step).with(steps.first, step_definitions).in_sequence(hooks)

            Spinach.hooks.expects(:run_before_step).with(steps.last, step_definitions).in_sequence(hooks)
            subject.expects(:run_step).with(steps.last)
            Spinach.hooks.expects(:run_after_step).with(steps.last, step_definitions).in_sequence(hooks)

            Spinach.hooks.expects(:run_after_scenario).with(scenario, step_definitions).in_sequence(hooks)

            subject.run
          end

          it "runs before_each before run steps" do
            before_each = sequence('before_each')
            subject.stubs(:steps).returns steps = stub
            step_definitions.expects(:before_each).in_sequence(before_each)
            steps.expects(:each).in_sequence(before_each)
            subject.run
          end

          it "runs after_each after run steps" do
            after_each = sequence('after_each')
            Spinach.hooks.expects(:run_after_step).in_sequence(after_each).twice
            step_definitions.expects(:after_each).in_sequence(after_each)
            subject.run
          end

          it 'raises if around_scenario hook does not yield' do
            subject.stubs(:step_definitions).returns stub

            Spinach.hooks.stubs(:run_around_scenario).with(scenario, step_definitions)

            e = proc do
              subject.run
            end.must_raise Spinach::HookNotYieldException
            e.hook.must_match /around_scenario/
          end

          it 'raises if around_step hook does not yield' do
            step_definitions.stubs(:step_location_for)

            Spinach.hooks.stubs(:run_around_step).with(steps.first, step_definitions)

            e = proc do
              subject.run
            end.must_raise Spinach::HookNotYieldException
            e.hook.must_match /around_step/
          end
        end
      end

      describe '#run_step' do
        before do
          @step             = stub(name: 'Go shopping', keyword: "key")
          @step_definitions = stub
          @step_definitions.stubs(:step_location_for).with('Go shopping').returns @location = [ "" ]
          subject.stubs(:step_definitions).returns @step_definitions
        end

        describe 'when the step is successful' do
          it 'runs the successful hooks' do
            @step_definitions.stubs(:execute).with(@step).returns true
            Spinach.hooks.expects(:run_on_successful_step).with(@step, @location, @step_definitions)

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
            Spinach.hooks.expects(:run_on_failed_step).with(@step, kind_of(@failure_exception), @location, @step_definitions)
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
            Spinach.hooks.expects(:run_on_undefined_step).with(@step, kind_of(Spinach::StepNotDefinedException), @step_definitions)
            subject.run_step(@step)
          end
        end

        describe 'when the step is pending' do
          before do
            @step_definitions.
              stubs(:execute).
              with(@step).
              raises Spinach::StepPendingException, @step
          end

          it 'does not set the exception' do
            subject.run_step(@step)
            subject.instance_variable_get(:@exception).must_be_kind_of(NilClass)
          end

          it 'sets the has_pending_step' do
            subject.run_step(@step)
            subject.instance_variable_get(:@has_pending_step).must_equal(true)
          end

          it 'runs the pending hooks' do
            Spinach.hooks.expects(:run_on_pending_step).with(@step, kind_of(Spinach::StepPendingException))
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
            Spinach.hooks.expects(:run_on_error_step).with(@step, kind_of(StandardError), @location, @step_definitions)
            subject.run_step(@step)
          end
        end
      end
    end
  end
end
