require_relative '../test_helper'

describe Spinach::Hooks do
  subject do
    Spinach::Hooks.new
  end

  describe "hooks" do
    %w{before_run after_run before_feature after_feature on_undefined_feature
    before_scenario after_scenario before_step after_step on_successful_step
    on_failed_step on_error_step on_undefined_step on_skipped_step}.each do |callback|
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

end
