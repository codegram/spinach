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

  describe '#scoped_camelize' do
    it 'prepends a scope to the class' do
      Spinach::Support.scoped_camelize('feature name').must_equal 'Spinach::Features::FeatureName'
    end
  end

  describe '#underscore' do
    it 'changes dashes to underscores' do
      Spinach::Support.underscore('feature-name').must_equal 'feature_name'
    end

    it 'downcases the text' do
      Spinach::Support.underscore('FEATURE').must_equal 'feature'
    end

    it 'converts namespaces to paths' do
      Spinach::Support.underscore('Spinach::Support').must_equal 'spinach/support'
    end

    it 'prepends underscores to uppercase letters' do
      Spinach::Support.underscore('FeatureName').must_equal 'feature_name'
    end

    it 'only prepends underscores to the last uppercase letter' do
      Spinach::Support.underscore('SSLError').must_equal 'ssl_error'
    end

    it 'does not modify the original string' do
      text = 'FeatureName'
      underscored_text = Spinach::Support.underscore(text)

      text.wont_equal underscored_text
    end

    it 'accepts non string values' do
      Spinach::Support.underscore(:FeatureName).must_equal 'feature_name'
    end

    it 'changes spaces to underscores' do
      Spinach::Support.underscore('feature name').must_equal 'feature_name'
    end
  end

  describe "#escape" do
    it "escapes the name" do
      Spinach::Support.escape_single_commas(
        "I've been doing things I shouldn't be doing"
      ).must_include "I\\'ve been doing things I shouldn\\'t be doing"
    end
  end

  describe '#constantize' do
    it "converts a string into a class" do
      Spinach::Support.constantize("Spinach::FeatureSteps").must_equal Spinach::FeatureSteps
    end
  end
end
