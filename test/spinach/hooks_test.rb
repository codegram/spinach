require_relative '../test_helper'

describe Spinach::Hooks do
  subject do
    Spinach::Hooks.new
  end

  describe "hooks" do
    %w{
      before_run
      after_run
      before_feature
      after_feature
      on_undefined_feature
      before_scenario
      after_scenario
      before_step
      after_step
      on_successful_step
      on_failed_step
      on_error_step
      on_undefined_step
      on_skipped_step
      on_pending_step
    }.each do |callback|
      describe "#{callback}" do
        it "responds to #{callback}" do
          subject.must_respond_to callback
        end

        it "executes the hook with params" do
          array = []
          block = Proc.new do |arg1, arg2|
            array << arg1
            array << arg2
          end
          subject.send(callback, &block)
          subject.send("run_#{callback}", 1, 2)
          array.must_equal [1, 2]
        end
      end
    end

    describe "around_scenario" do
      it "responds to around_scenario" do
        subject.must_respond_to :around_scenario
      end

      it "executes the hook with params" do
        array = []
        block = Proc.new do |arg1, arg2|
          array << arg1
          array << arg2
        end
        subject.send(:around_scenario, &block)
        subject.send("run_around_scenario", 1, 2) do
        end
        array.must_equal [1, 2]
      end
    end

    describe "around_step" do
      it "responds to around_step" do
        subject.must_respond_to :around_step
      end

      it "executes the hook with params" do
        array = []
        block = Proc.new do |arg1, arg2|
          array << arg1
          array << arg2
        end
        subject.send(:around_step, &block)
        subject.send("run_around_step", 1, 2) do
        end
        array.must_equal [1, 2]
      end
    end

    describe "#on_tag" do
      let(:scenario) do
        stub(tags: ['javascript', 'capture'])
      end
      let(:step_definitions) do
        stub(something: "step_definitions")
      end

      it "calls the block if the scenario includes the tag" do
        assertion = false
        subject.on_tag('javascript') do
          assertion = true
        end
        subject.run_before_scenario(scenario, step_definitions)
        assertion.must_equal true
      end

      it "passes in the step_definitions" do
        assertion = false
        subject.on_tag('javascript') do |scenario, step_definitions|
          assertion = step_definitions.something
        end
        subject.run_before_scenario(scenario, step_definitions)
        assertion.must_equal "step_definitions"
      end

      it "doesn't call the block if the scenario doesn't include the tag" do
        assertion = false
        subject.on_tag('screenshot') do
          assertion = true
        end
        subject.run_before_scenario(scenario)
        assertion.wont_equal true
      end
    end
  end
end
