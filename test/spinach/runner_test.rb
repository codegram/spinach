require_relative '../test_helper'

describe Spinach::Runner do
  before do
    Spinach.reset_features
    @feature = Class.new(Spinach::Feature) do
      feature "A new feature"
      When "I say hello" do
      end
      Then "You say goodbye" do
      end
    end
    data = {
      'name' => "A new feature",
      'elements' => [{'steps' => [
        {'name' => "I say hello"}, {'name' => "You say goodbye"}
      ]}]
    }
    @runner = Spinach::Runner.new(data)
  end
  describe "#feature" do
    it "returns a Spinach feature" do
      @runner.feature.name == @feature.name
    end
  end
  describe "#scenarios" do
    it "should return the scenarios" do
      @runner.scenarios.must_equal [{'steps' => [
        {'name' => "I say hello"}, {'name' => "You say goodbye"}
      ]}]
    end
  end
  describe "#run" do
    it "should call every step on the feature" do
      @runner.run
    end
  end
end
