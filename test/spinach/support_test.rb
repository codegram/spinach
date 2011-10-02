require_relative '../test_helper'

describe Spinach::Support do
  describe '#camelize' do
    it 'returns an empty string with nil values' do
      Spinach::Support.camelize(nil).must_equal ''
    end

    it 'downcases the given value' do
      Spinach::Support.camelize('VALUE').must_equal 'Value'
    end

    it 'squeezes the spaces for the given value' do
      Spinach::Support.camelize('feature  name').must_equal 'FeatureName'
    end

    it 'strips the given value' do
      Spinach::Support.camelize('  value  ').must_equal 'Value'
    end

    it 'strips the given value' do
      Spinach::Support.camelize('feature name').must_equal 'FeatureName'
    end
  end
end
