require_relative '../test_helper'

describe Spinach::Helpers do
  describe '.constantize' do
    it "converts a string into a class" do
      Spinach::Helpers.constantize("Spinach::FeatureSteps").must_equal Spinach::FeatureSteps
    end
  end
end
