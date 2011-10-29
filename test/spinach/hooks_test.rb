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

  describe "hooks with tag filters" do
    before do
      feature_data = {
        'name' => 'My ridiculously awesome feature',
        'elements' => [
          {"name" => "scenario", "steps" => ["",""]}
        ],
        "tags" => [{"name" => "@cool", "line" => 1}]
      }
      @feature = Spinach::Runner::FeatureRunner.new("my_feature")
      @feature.stubs(:data).returns(feature_data)
      @@flag = 0
    end

    it "if any tag filter is set only executes those that match it" do
      Spinach.hooks.before_feature :tags => "@cool" do |data|
        @@flag = 1
      end
      Spinach.hooks.before_feature :tags => ["@lame","@so_so"] do |data|
        @@flag = 2
      end

      @@flag.must_equal 0
      @feature.run
      @@flag.must_equal 1
    end
  end
end
