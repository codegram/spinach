require_relative '../test_helper'

describe Spinach::DSL do
  before do
    @feature = Class.new do
      extend Spinach::DSL
    end
  end
  %w{When Given Then And But}.each do |connector|
    describe "##{connector}" do
      it "should define a method with the step name" do
        @feature.send(connector, "I say goodbye") do
          "You say hello"
        end
        @feature.new.send("#{connector} I say goodbye").must_equal "You say hello"
      end
    end
  end
  describe "#Given, #Then, #And, #But" do
    it "should be #When aliases" do
      %w{Given Then And But}.each do |m|
        @feature.must_respond_to m
      end
    end
  end
  describe "#feature" do
    it "should set the name for this feature" do
      @feature.feature("User salutes")
      @feature.feature_name.must_equal "User salutes"
    end
  end
end
