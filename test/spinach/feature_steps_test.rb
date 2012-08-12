require_relative '../test_helper'

describe Spinach::FeatureSteps do
  describe 'ancestors' do
    it 'is extended by the DSL' do
      Spinach::FeatureSteps.ancestors.must_include Spinach::DSL
    end
  end

  describe 'class methods' do
    describe '#inherited' do
      it 'registers any feature subclass' do
        @feature_steps1 = Class.new(Spinach::FeatureSteps)
        @feature_steps2 = Class.new(Spinach::FeatureSteps)
        @feature_steps3 = Class.new

        Spinach.feature_steps.must_include @feature_steps1
        Spinach.feature_steps.must_include @feature_steps2
        Spinach.feature_steps.wont_include @feature_steps3
      end
    end
  end

  describe 'instance methods' do
    let(:feature) do
      Class.new(Spinach::FeatureSteps) do
        When 'I go to the toilet' do
          @pee = true
        end
        attr_reader :pee
      end.new
    end

    it "responds to before_each" do
      feature.must_respond_to(:before_each)
    end

    it "responds to after_each" do
      feature.must_respond_to(:after_each)
    end

    describe 'execute' do
      it 'runs defined step correctly' do
        feature.execute(stub(name: 'I go to the toilet'))

        feature.pee.must_equal true
      end

      it 'raises an exception if step is not defined' do
        proc {
          feature.execute(stub(name: 'I am lost'))
        }.must_raise Spinach::StepNotDefinedException
      end
    end
  end

end
