require_relative 'test_helper'

describe Spinach do
  before do
    @feature1 = OpenStruct.new(feature_name: "User authentication")
    @feature2 = OpenStruct.new(feature_name: "Slip management")
    @feature3 = OpenStruct.new(feature_name: "File attachments")
    [@feature1, @feature2, @feature3].each do |feature|
      Spinach.features << feature
    end
  end
  describe "#features" do
    it "returns all the loaded features" do
      Spinach.features.must_include @feature1
      Spinach.features.must_include @feature2
      Spinach.features.must_include @feature3
    end
  end
  describe "#reset_features" do
    it "resets the features to a pristine state" do
      Spinach.reset_features
      [@feature1, @feature3, @feature3].each do |feature|
        Spinach.features.wont_include feature
      end
    end
  end
  describe "#find_feature" do
    it "finds a feature by name" do
      Spinach.find_feature("User authentication").must_equal @feature1
      Spinach.find_feature("Slip management").must_equal @feature2
      Spinach.find_feature("File attachments").must_equal @feature3
    end
  end
end
