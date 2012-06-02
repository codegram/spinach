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

    it "defines a new around hook" do
      subject.class.around_hook :around_save
      subject.must_respond_to :around_save
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

      it "allows to run around hook" do
        arbitrary_variable = false
        subject.add_hook(:around_save) do |&block|
          arbitrary_variable = true
          block.call
        end
        subject.run_around_hook(:around_save) do
        end
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

      it "allows to run an around hook" do
        array = []
        subject.add_hook(:around_save) do |var1, var2, &block|
          array << var1
          array << var2
          block.call
        end
        subject.run_around_hook(:around_save, 1, 2) do
        end
        array.must_equal [1, 2]
      end

      it "yields to hook block even if nothing is hooked" do
        called = false
        subject.run_hook(:before_save) do
          called = true
        end
        called.must_equal true
      end

      it "yields to around hook block even if nothing is hooked" do
        called = false
        subject.run_hook(:around_save) do
          called = true
        end
        called.must_equal true
      end
    end

    describe "order" do
      it "runs hooks in registration order" do
        save = sequence("save")
        object = mock("object")
        object.expects(:before_first).in_sequence(save)
        object.expects(:before_second).in_sequence(save)

        subject.add_hook(:before_save) do
          object.before_first
        end
        subject.add_hook(:before_save) do
          object.before_second
        end
        subject.run_hook(:before_save)
      end

      it "runs around hooks in registration order" do
        save = sequence("save")
        object = mock("object")
        object.expects(:before_first).in_sequence(save)
        object.expects(:before_second).in_sequence(save)
        object.expects(:after_second).in_sequence(save)
        object.expects(:after_first).in_sequence(save)

        subject.add_hook(:around_save) do |&block|
          object.before_first
          block.call
          object.after_first
        end
        subject.add_hook(:around_save) do |&block|
          object.before_second
          block.call
          object.after_second
        end

        subject.run_around_hook(:around_save) {}
      end
    end

    it "requires a block when running around hook" do
      subject.add_hook(:around_save) do
      end
      lambda {
        subject.run_around_hook(:around_save)
      }.must_raise ArgumentError
    end

    it "runs around hook block only once" do
      object = mock("object")
      object.expects(:save).once
      subject.add_hook(:around_save){|&block| block.call}
      subject.add_hook(:around_save){|&block| block.call}
      subject.run_around_hook(:around_save){ object.save }
    end

    describe "#reset_hooks" do
      it "resets the hooks to a pristine state" do
        subject.add_hook(:before_save)
        (subject.hooks.empty?).must_equal false
        subject.reset
        (subject.hooks.empty?).must_equal true
      end
    end
  end
end
