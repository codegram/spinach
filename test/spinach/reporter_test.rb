# encoding: utf-8
require_relative '../test_helper'

module Spinach
  describe Reporter do
    before do
      @options = {
        backtrace: true
      }
      @reporter = Reporter.new(@options)
    end

    describe "#options" do
      it "returns the options passed to the reporter" do
        @reporter.options[:backtrace].must_equal true
      end
    end

    describe "#current_feature" do
      it "returns nil by default" do
        @reporter.current_feature.must_equal nil
      end
    end

    describe "#current_scenario" do
      it "returns nil by default" do
        @reporter.current_feature.must_equal nil
      end
    end

    %w{undefined_steps failed_steps error_steps}.each do |errors|
      describe "##{errors}" do
        it "returns an empty array by default" do
          @reporter.send(errors).must_be_empty
        end
      end
    end

    describe "#bind" do
      before do
        @reporter.stubs(
          runner: stub_everything,
          feature_runner: stub_everything,
          scenario_runner: stub_everything,
        )
        @callback = mock
        @reporter.stubs(:method)
      end

      describe "bindings" do
        before do
          Spinach.hooks.reset
          @reporter.bind
        end

        after do
          Spinach.hooks.reset
        end

        it "binds a callback before running" do
          @reporter.expects(:before_run)
          Spinach.hooks.run_before_run
        end

        it "binds a callback after running" do
          @reporter.expects(:after_run)
          Spinach.hooks.run_after_run
        end

        it "binds a callback before running every feature" do
          @reporter.expects(:before_feature_run)
          Spinach.hooks.run_before_feature(anything)
        end

        it "binds a callback after running every feature" do
          @reporter.expects(:after_feature_run)
          Spinach.hooks.run_after_feature
        end

        it "binds a callback when a feature is not found" do
          @reporter.expects(:on_feature_not_found)
          Spinach.hooks.run_on_undefined_feature
        end

        it "binds a callback before every scenario" do
          @reporter.expects(:before_scenario_run)
          Spinach.hooks.run_before_scenario(stub_everything)
        end

        it "binds a callback around every scenario" do
          @reporter.expects(:around_scenario_run)
          Spinach.hooks.run_around_scenario(anything) do
            yield
          end
        end

        it "yields to around scenario callback" do
          called = false
          @reporter.around_scenario_run do
            called = true
          end
          called.must_equal true
        end

        it "binds a callback after every scenario" do
          @reporter.expects(:after_scenario_run)
          Spinach.hooks.run_after_scenario
        end

        it "binds a callback after every successful step" do
          @reporter.expects(:on_successful_step)
          Spinach.hooks.run_on_successful_step
        end

        it "binds a callback after every failed step" do
          @reporter.expects(:on_failed_step)
          Spinach.hooks.run_on_failed_step
        end

        it "binds a callback after every error step" do
          @reporter.expects(:on_error_step)
          Spinach.hooks.run_on_error_step
        end

        it "binds a callback after every skipped step" do
          @reporter.expects(:on_skipped_step)
          Spinach.hooks.run_on_skipped_step
        end

        describe "internals" do
          it "binds a callback before running" do
            @reporter.expects(:set_current_feature)
            Spinach.hooks.run_before_feature({})
          end

          it "binds a callback after running" do
            @reporter.expects(:clear_current_feature)
            Spinach.hooks.run_after_feature
          end

          it "binds a callback before every scenario" do
            @reporter.expects(:set_current_scenario)
            Spinach.hooks.run_before_scenario
          end

          it "binds a callback after every scenario" do
            @reporter.expects(:clear_current_scenario)
            Spinach.hooks.run_after_scenario
          end
        end
      end
    end
  end
end
