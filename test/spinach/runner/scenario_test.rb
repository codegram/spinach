require_relative '../../test_helper'

describe Spinach::Runner::Scenario do
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
    @data = {'name' => 'First scenario', 'steps' => [
      {'keyword' => 'When ', 'name' => "I say hello"},
      {'keyword' => 'Then ', 'name' => "you say goodbye"},
      {'keyword' => 'And ', 'name' => "get the fuck out"}]
    }
    @reporter = stub_everything
    @runner = stub(reporter: @reporter, feature: @feature)
    @scenario = Spinach::Runner::Scenario.new(@runner, @data)
  end

  it "should call every step on the feature" do
    @scenario.run
    @scenario.feature.when_called.must_equal true
    @scenario.feature.then_called.must_equal true
  end

  it "calls the appropiate methods of the reporter, included a failure" do
    @reporter.expects(:scenario).with("First scenario")
    @reporter.expects(:step).once.with("When I say hello", :success)
    @reporter.expects(:step).once.with("Then you say goodbye", :failure)
    @reporter.expects(:step).once.with("And get the fuck out", :skip)
    @scenario.run
  end

  it "calls the appropiate methods of the reporter, included an undefined step" do
    @data = {'name' => 'First scenario', 'steps' => [
      {'keyword' => 'When ', 'name' => "I say hello"},
      {'keyword' => 'Then ', 'name' => "you fart"},
      {'keyword' => 'And ', 'name' => "get the fuck out"}]
    }
    @scenario = Spinach::Runner::Scenario.new(@runner, @data)

    @reporter.expects(:scenario).with("First scenario")
    @reporter.expects(:step).once.with("When I say hello", :success)
    @reporter.expects(:step).once.with("Then you fart", :undefined_step)
    @reporter.expects(:step).once.with("And get the fuck out", :skip)
    @scenario.run
  end

  it "stops the run when finds an error" do
    @feature = Class.new(Spinach::Feature) do
      feature "A new feature"
      When "I say hello" do
        @when_called = true
        true.must_equal false
      end
      Then "you say goodbye" do
        @then_called = true
      end
      attr_accessor :when_called, :then_called
    end
    @runner.stubs(feature: @feature)
    @scenario = Spinach::Runner::Scenario.new(@runner, @data)
    @scenario.run
    @scenario.feature.when_called.must_equal true
    @scenario.feature.then_called.wont_equal true
  end
end
