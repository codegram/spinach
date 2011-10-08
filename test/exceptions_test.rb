require_relative 'test_helper'

describe Spinach::FeatureNotFoundException do
  subject do
    Spinach::FeatureNotFoundException.new(['ThisFeatureDoesNotExist', 'This feature does not exist'])
  end

  describe 'message' do
    it 'tells the user that the steps could not be found' do
      subject.message.must_include 'Could not find steps for `This feature does not exist` feature.'
    end

    it 'tells the user to create the file' do
      subject.message.must_include 'Please create the file this_feature_does_not_exist.rb'
    end

    it 'tells the user where to create the file' do
      subject.message.must_include 'at features/steps, with:'
    end

    it 'tells the user where to create the file using a custom path' do
      Spinach.config.stubs(:step_definitions_path).returns('my/path')
      subject.message.must_include 'at my/path, with:'
    end

    it 'tells the user what to write in the file' do
      subject.message.must_include 'class ThisFeatureDoesNotExist << Spinach::Feature'
    end
  end
end
