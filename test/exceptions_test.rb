require_relative 'test_helper'

describe Spinach::FeatureStepsNotFoundException do
  subject do
    Spinach::FeatureStepsNotFoundException.new(['ThisFeatureDoesNotExist', 'This feature does not exist'])
  end

  describe 'message' do
    it 'tells the user that the steps could not be found' do
      subject.message.must_include 'Could not find steps for `This feature does not exist` feature'
    end
  end
end
