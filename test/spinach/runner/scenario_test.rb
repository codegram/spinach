require_relative '../../test_helper'

describe Spinach::Runner::Scenario do
  before do
    @data = {
      'name' => 'A cool scenario',
      'steps' => [
        {'keyword' => 'Given', 'name' => 'I herd you like steps'},
        {'keyword' => 'When', 'name' => 'I test steps'},
        {'keyword' => 'Then', 'name' => 'I go step by step'}
      ]
    }
    @feature = stub_everything
    @feature_name = "My feature"
    @reporter = stub_everything
    @scenario = Spinach::Runner::Scenario.new(@feature_name, @feature, @data, @reporter)
  end

  describe '#initialize' do
    it 'initializes a scenario name' do
      @scenario.name.must_equal 'A cool scenario'
    end

    it 'lists all the steps' do
      @scenario.steps.count.must_equal 3
    end

    it 'sets the reporter' do
      @scenario.reporter.must_equal @reporter
    end

    it 'sets the feature' do
      @scenario.feature.must_equal @feature
    end
  end

  describe '#run' do
    it 'calls the appropiate feature steps' do
      @feature.expects(:execute_step).with('I herd you like steps')
      @feature.expects(:execute_step).with('I test steps')
      @feature.expects(:execute_step).with('I go step by step')
      @scenario.run
    end

    describe 'when throwing exceptions' do
      it 'rescues a MiniTest::Assertion' do
        @feature.expects(:execute_step).raises(MiniTest::Assertion)
        @reporter.expects(:step).with(anything, anything, :failure)
        @scenario.run
      end

      it 'rescues a Spinach::StepNotDefinedException' do
        @feature.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('foo', 'bar'))
        @reporter.expects(:step).with(anything, anything, :undefined_step)
        @scenario.run
      end

      it 'rescues any other error' do
        @feature.expects(:execute_step).raises
        @reporter.expects(:step).with(anything, anything, :error)
        @scenario.run
      end

      it "returns an failure" do
        @feature.expects(:execute_step).raises(MiniTest::Assertion)
        @scenario.run.wont_equal nil
      end

    end

    it 'runs a step' do
      @reporter.expects(:step).with(anything, anything, :success).times(3)
      @scenario.run.must_equal nil
    end

    describe "hooks" do
      it "fires up the scenario hooks" do
        @feature.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('foo', 'bar'))
        @feature.expects(:run_hook).with(:before_scenario, "A cool scenario")
        @feature.expects(:run_hook).with(:after_scenario, "A cool scenario")
        @scenario.run
      end
      it "fires up the step hooks" do
        @feature.expects(:execute_step).raises(Spinach::StepNotDefinedException.new('foo', 'bar'))
        %w{before_step after_step}.each do |hook|
          @feature.expects(:run_hook).with(
            hook.to_sym, "Given", "I herd you like steps")
          @feature.expects(:run_hook).with(
            hook.to_sym, "When", "I test steps")
          @feature.expects(:run_hook).with(
            hook.to_sym, "Then", "I go step by step")
        end
        @scenario.run
      end
    end
  end
end
