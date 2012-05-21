require_relative '../test_helper'

describe Spinach::Hookable do
  subject do
    Class.new do
      include Spinach::Hookable
    end.new
  end

  describe ".define_hook" do
    it "defines a new hook" do
      subject.class.hook :before_save
      subject.must_respond_to :before_save
    end
  end

  describe "hooking mechanism" do
    describe "without params" do
      it "adds a new hook to the queue" do
        subject.add_hook(:before_save) do
        end
        (subject.hooks_for(:before_save).empty?).must_equal false
      end

      it "allows to run a hook" do
        arbitrary_variable = false
        subject.add_hook(:before_save) do
          arbitrary_variable = true
        end
        subject.run_hook(:before_save)
        arbitrary_variable.must_equal true
      end

      it "runs multiple around_scenario executing the scenario block only once" do
        scenario_block_called_times = 0
        scenario_run = Proc.new{ scenario_block_called_times += 1 }
        first_around_ran = false
        second_around_ran = false
        scenario_data_arg = mock
        steps_arg = mock

        subject.add_hook(:around_scenario) do |scenario_data, steps, &block|
          first_around_ran = true
          scenario_data.must_equal scenario_data_arg
          steps.must_equal steps_arg
          block.call
        end
        subject.add_hook(:around_scenario) do |scenario_data, steps, &block|
          second_around_ran = true
          scenario_data.must_equal scenario_data_arg
          steps.must_equal steps_arg
          block.call
        end
        subject.hooks[:around_scenario].size.must_equal 2

        subject.run_hook(:around_scenario, scenario_data_arg, steps_arg, &scenario_run)

        scenario_block_called_times.must_equal 1
        first_around_ran.must_equal true
        second_around_ran.must_equal true
        subject.hooks[:around_scenario].size.must_equal 2
      end
    end

    describe "with params" do
      it "adds a new hook to the queue" do
        subject.add_hook(:before_save) do |var1, var2|
        end
        (subject.hooks_for(:before_save).empty?).must_equal false
      end

      it "allows to run a hook" do
        array = []
        subject.add_hook(:before_save) do |var1, var2|
          array << var1
          array << var2
        end
        subject.run_hook(:before_save, 1, 2)
        array.must_equal [1, 2]
      end

      it "yields to hook block even if nothing is hooked" do
        called = false
        subject.run_hook(:before_save) do
          called = true
        end
        called.must_equal true
      end
    end

    describe "#reset_hooks" do
      it "resets the hooks to a pristine state" do
        subject.add_hook(:before_save)
      end
    end
  end
end
