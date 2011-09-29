require_relative '../test_helper'

describe Spinach::Feature do
  describe "ancestors" do
    it "should include minitest helpers" do
      Spinach::Feature.ancestors.must_include MiniTest::Assertions
    end

    it "should be extended by the DSL" do
      (class << Spinach::Feature; self; end).ancestors.must_include Spinach::DSL
    end
  end

  describe 'class methods' do
    describe "#inherited" do
      it "should register any feature subclass" do
        @feature1 = Class.new(Spinach::Feature)
        @feature2 = Class.new(Spinach::Feature)
        @feature3 = Class.new
        Spinach.features.must_include @feature1
        Spinach.features.must_include @feature2
        Spinach.features.wont_include @feature3
      end
    end
  end

  describe 'instance methods' do
    before do
      @feature = Class.new(Spinach::Feature) do
        When "I go to the toilet" do
          @pee = true
        end
        attr_reader :pee
      end.new
    end

    describe 'execute_step' do
      it 'runs defined step correctly' do
        @feature.execute_step("When", "I go to the toilet")
        @feature.pee.must_equal true
      end

      it 'raises an exception if step is not defined' do
        Proc.new {
          @feature.execute_step "Given", "I am lost"
        }.must_raise Spinach::StepNotDefinedException
      end
    end
  end
end
