require_relative '../test_helper'

describe Spinach::Feature do
  describe "ancestors" do
    it 'includes minitest helpers' do
      Spinach::Feature.ancestors.must_include MiniTest::Assertions
    end

    it 'is extended by the DSL' do
      Spinach::Feature.ancestors.must_include Spinach::DSL
    end
  end

  describe 'class methods' do
    describe '#inherited' do
      it 'registers any feature subclass' do
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
        When 'I go to the toilet' do
          @pee = true
        end
        attr_reader :pee
      end.new
    end

    describe 'execute_step' do
      it 'runs defined step correctly' do
        @feature.execute_step('I go to the toilet')

        @feature.pee.must_equal true
      end

      it 'raises an exception if step is not defined' do
        proc {
          @feature.execute_step 'I am lost'
        }.must_raise Spinach::StepNotDefinedException
      end
    end
  end

  describe "Object#Feature" do
    it "creates a feature class" do
      feature = Feature("Hola") do
        attr_accessor :test
        When "Test" do
          self.test = true
        end
      end
      Spinach.features.must_include feature
      instance = feature.new
      instance.execute_step("Test")
      instance.test.must_equal true
    end
  end
end
