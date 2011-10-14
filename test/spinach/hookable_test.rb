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
    end

    describe "#reset_hooks" do
      it "resets the hooks to a pristine state" do
        subject.add_hook(:before_save)
      end
    end
  end
end
