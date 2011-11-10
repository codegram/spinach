require_relative '../../test_helper'

describe Spinach::Runner::FeatureRunner do
  let(:feature) { stub('feature', name: 'Feature') }
  subject{ Spinach::Runner::FeatureRunner.new(feature) }

  describe '#initialize' do
    it 'initializes the given filename' do
      subject.feature.must_equal feature
    end

    it 'initalizes the given scenario line' do
      @runner = Spinach::Runner::FeatureRunner.new(feature, '34')
      @runner.instance_variable_get(:@line).must_equal 34
    end
  end

  describe '#scenarios' do
    it 'delegates to the feature' do
      subject.feature.stubs(scenarios: [1,2,3])
      subject.scenarios.must_equal [1,2,3]
    end
  end

  describe '#run' do
    it 'runs the hooks in order' do
      hooks = sequence('hooks')
      Spinach.hooks.expects(:run_before_feature).with(feature).in_sequence(hooks)
      Spinach.expects(:find_feature_steps).returns(false).in_sequence(hooks)
      Spinach.hooks.expects(:run_after_feature).with(feature).in_sequence(hooks)

      subject.run
    end

    describe 'when the steps exist' do
      before do
        @feature = stub('feature', name: 'Feature')
        Spinach.stubs(:find_feature_steps).returns(true)
        @scenarios = [
          scenario         = stub,
          another_scenario = stub
        ]
        @feature.stubs(:scenarios).returns @scenarios
        @runner = Spinach::Runner::FeatureRunner.new(@feature)
      end

      describe 'and the scenarios pass' do
        it 'runs the scenarios and returns true' do
          @scenarios.each do |scenario|
            runner = stub(run: true)
            Spinach::Runner::ScenarioRunner.expects(:new).with('Feature', scenario).returns runner
          end

          @runner.run.must_equal true
        end
      end

      describe 'and the scenarios fail' do
        it 'runs the scenarios and returns false' do
          @scenarios.each do |scenario|
            runner = stub(run: false)
            Spinach::Runner::ScenarioRunner.expects(:new).with('Feature', scenario).returns runner
          end

          @runner.run.must_equal false
        end
      end
    end

    describe "when the steps don't exist" do
      it 'runs the corresponding hooks and returns false' do
        Spinach.stubs(:find_feature_steps).returns(false)
        Spinach.hooks.expects(:run_on_undefined_feature).with(feature)
        subject.run.must_equal false
      end
    end
  end
end
