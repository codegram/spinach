require_relative '../test_helper'

describe Spinach::Support do
  describe '#camelize' do
    it 'returns an empty string with nil values' do
      Spinach::Support.camelize(nil).must_equal ''
    end

    it 'downcases the given value' do
      ActiveSupport::Inflector.expects(:camelize).with('value').returns('value')

      Spinach::Support.camelize('VALUE').must_equal 'value'
    end

    it 'squeezes the spaces for the given value' do
      ActiveSupport::Inflector.expects(:camelize).with('feature_name').returns('FeatureName')

      Spinach::Support.camelize('feature  name').must_equal 'FeatureName'
    end

    it 'strips the given value' do
      ActiveSupport::Inflector.expects(:camelize).with('value').returns('value')

      Spinach::Support.camelize('  value  ').must_equal 'value'
    end

    it 'strips the given value' do
      ActiveSupport::Inflector.expects(:camelize).with('feature_name').returns('FeatureName')

      Spinach::Support.camelize('feature name').must_equal 'FeatureName'
    end
  end
end
