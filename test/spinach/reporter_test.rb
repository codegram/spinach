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

    describe "#initialize" do
      it "initializes the option hash" do
      end
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

      it "binds a callback after running all the suite" do
        @reporter.expects(:method).with(:after_run).returns(@callback)
        @reporter.runner.expects(:after_run).with(@callback)
        @reporter.bind
      end

      it "binds a callback before running every feature" do
        @reporter.expects(:method).with(:before_feature_run).returns(@callback)
        @reporter.feature_runner.expects(:before_run).with(@callback)
        @reporter.bind
      end

      it "binds a callback after running every feature" do
        @reporter.expects(:method).with(:after_feature_run).returns(@callback)
        @reporter.feature_runner.expects(:after_run).with(@callback)
        @reporter.bind
      end

      it "binds a callback for not defined features" do
        @reporter.expects(:method).with(:on_feature_not_found).returns(@callback)
        @reporter.feature_runner.expects(:when_not_found).with(@callback)
        @reporter.bind
      end

      it "binds a callback before running every scenario" do
        @reporter.expects(:method).with(:before_scenario_run).returns(@callback)
        @reporter.scenario_runner.expects(:before_run).with(@callback)
        @reporter.bind
      end

      it "binds a callback after running every feature" do
        @reporter.expects(:method).with(:after_scenario_run).returns(@callback)
        @reporter.scenario_runner.expects(:after_run).with(@callback)
        @reporter.bind
      end

      describe "when running steps" do
        %w{successful failed error skipped}.each do |type|
          it "binds a callback after running a #{type} step" do
            @reporter.expects(:method).with(:"on_#{type}_step").returns(@callback)
            @reporter.scenario_runner.expects(:"on_#{type}_step").with(@callback)
            @reporter.bind
          end
        end
      end

      describe "binds the context methods" do
        it "binds the current feature setter" do
          @reporter.expects(:method).with(:current_feature=).returns(@callback)
          @reporter.feature_runner.expects(:before_run).with(@callback)
          @reporter.bind
        end

        it "binds the current feature clearer" do
          @reporter.expects(:method).with(:clear_current_feature).returns(@callback)
          @reporter.feature_runner.expects(:after_run).with(@callback)
          @reporter.bind
        end

        it "binds the current scenario setter" do
          @reporter.expects(:method).with(:current_scenario=).returns(@callback)
          @reporter.scenario_runner.expects(:before_run).with(@callback)
          @reporter.bind
        end

        it "binds the current feature clearer" do
          @reporter.expects(:method).with(:clear_current_scenario).returns(@callback)
          @reporter.scenario_runner.expects(:after_run).with(@callback)
          @reporter.bind
        end
      end
    end

    describe "#clear_current_feature" do
      it "clears the current feature" do
        @reporter.current_feature = mock
        @reporter.clear_current_feature
        @reporter.current_feature.must_equal nil
      end
    end

    describe "#clear_current_scenario" do
      it "clears the current scenario" do
        @reporter.current_scenario = mock
        @reporter.clear_current_scenario
        @reporter.current_scenario.must_equal nil
      end
    end

    describe "runner classes" do
      describe "#feature_runner" do
        it "returns a runner class" do
          @reporter.feature_runner.must_be_kind_of Class
        end
      end

      describe "#scenario_runner" do
        it "returns a runner class" do
          @reporter.scenario_runner.must_be_kind_of Class
        end
      end

      describe "#runner" do
        it "returns a runner class" do
          @reporter.runner.must_be_kind_of Class
        end
      end
    end

    describe "callback methods" do
      %w{
        after_run before_feature_run after_feature_run before_scenario_run
        after_scenario_run on_successful_step on_failed_step on_error_step
        on_undefined_step on_skipped_step
      }.each do |callback|
        describe "##{callback}" do
          it "does nothing" do
            @reporter.send(callback)
          end
        end
      end
    end
  end
end
