require_relative '../test_helper'

describe Spinach::Runner do
  before do
    Spinach.reset_features
    @feature = Class.new(Spinach::Feature) do
      feature "A new feature"
      When "I say hello" do
        @when_called = true
      end
      Then "you say goodbye" do
        @then_called = true
        true.must_equal false
      end
      attr_accessor :when_called, :then_called
    end
    data = {
      'name' => "A new feature",
      'elements' => [
        {'name' => 'First scenario', 'steps' => [
          {'keyword' => 'When ', 'name' => "I say hello"},
          {'keyword' => 'Then ', 'name' => "you say goodbye"}]
        }
      ]
    }
    @runner = Spinach::Runner.new(data)
  end
  describe "#feature" do
    it "returns a Spinach feature" do
      @runner.feature.must_be_kind_of @feature
    end
  end
  describe "#scenarios" do
    it "should return the scenarios" do
      @runner.scenarios.must_equal [
        {'name' => 'First scenario', 'steps' => [
          {'keyword' => 'When ', 'name' => "I say hello"},
          {'keyword' => 'Then ', 'name' => "you say goodbye"} ]
        }
      ]
    end
  end
  describe "#run" do
    it "should call every step on the feature" do
      @runner.stubs(reporter: stub_everything)
      feature = @runner.feature
      @runner.run
      feature.when_called.must_equal true
      feature.then_called.must_equal true
    end
    it "should hook into the reporter" do
      reporter = @runner.reporter
      reporter.expects(:feature).with("A new feature")
      reporter.expects(:scenario).with("First scenario")
      reporter.expects(:step).once.with("When I say hello", :success)
      reporter.expects(:step).once.with("Then you say goodbye", :failure)
      @runner.run
    end
  end
end
