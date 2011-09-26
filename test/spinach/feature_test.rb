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
    describe '#class_name' do
      it 'returns its class name as a string' do
        @feature = Class.new(Spinach::Feature) do
          def self.name
            'UserAuthentication'
          end
        end.new

        @feature.class_name.must_equal 'UserAuthentication'
      end
    end
  end
end
