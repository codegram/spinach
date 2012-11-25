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
      Spinach.expects(:find_step_definitions).returns(false).in_sequence(hooks)
      Spinach.hooks.expects(:run_after_feature).with(feature).in_sequence(hooks)

      subject.run
    end

    describe 'when the steps exist' do
      before do
        @feature = stub('feature', name: 'Feature')
        Spinach.stubs(:find_step_definitions).returns(true)
        @scenarios = [
          scenario         = stub(tags: []),
          another_scenario = stub(tags: [])
        ]
        @feature.stubs(:scenarios).returns @scenarios
        @runner = Spinach::Runner::FeatureRunner.new(@feature)
      end

      describe 'and the scenarios pass' do
        it 'runs the scenarios and returns true' do
          @scenarios.each do |scenario|
            runner = stub(run: true)
            Spinach::Runner::ScenarioRunner.expects(:new).with(scenario).returns runner
          end

          @runner.run.must_equal true
        end
      end

      describe 'and the scenarios fail' do
        it 'runs the scenarios and returns false' do
          @scenarios.each do |scenario|
            runner = stub(run: false)
            Spinach::Runner::ScenarioRunner.expects(:new).with(scenario).returns runner
          end

          @runner.run.must_equal false
        end
      end
    end

    describe "when the steps don't exist" do
      it 'runs the corresponding hooks and returns false' do
        Spinach.stubs(:find_step_definitions).returns(false)
        Spinach.hooks.expects(:run_on_undefined_feature).with(feature)
        subject.run.must_equal false
      end
    end

    describe "when a line is given" do
      before do
        @feature = stub('feature', name: 'Feature')
        Spinach.stubs(:find_step_definitions).returns(true)
        @scenarios = [
          scenario         = stub(line: 4, tags: []),
          another_scenario = stub(line: 12, tags: [])
        ]
        @feature.stubs(:scenarios).returns @scenarios
      end

      it "runs exactly matching scenario" do
        Spinach::Runner::ScenarioRunner.expects(:new).with(@scenarios[1]).returns stub(run: true)
        @runner = Spinach::Runner::FeatureRunner.new(@feature, "12")
        @runner.run
      end

      it "runs no scenario and returns false" do
        Spinach::Runner::ScenarioRunner.expects(:new).never
        @runner = Spinach::Runner::FeatureRunner.new(@feature, "3")
        @runner.run
      end

      it "runs matching scenario" do
        Spinach::Runner::ScenarioRunner.expects(:new).with(@scenarios[0]).returns stub(run: true)
        @runner = Spinach::Runner::FeatureRunner.new(@feature, "8")
        @runner.run
      end

      it "runs last scenario" do
        Spinach::Runner::ScenarioRunner.expects(:new).with(@scenarios[1]).returns stub(run: true)
        @runner = Spinach::Runner::FeatureRunner.new(@feature, "15")
        @runner.run
      end
    end

    describe "when running for specific tags configured" do

      describe "with feature" do
        before do
          @feature = stub('feature', name: 'Feature', tags: ["feature_tag"])
          Spinach.stubs(:find_step_definitions).returns(true)
          @scenario = stub(line: 4, tags: [])
          @feature.stubs(:scenarios).returns [@scenario]
        end

        it "runs matching feature" do
          Spinach::TagsMatcher.expects(:match).with(["feature_tag"]).returns true
          Spinach::Runner::ScenarioRunner.expects(:new).with(@scenario).returns stub(run: true)

          @runner = Spinach::Runner::FeatureRunner.new(@feature)
          @runner.run
        end
      end

      describe "with scenario" do
        before do
          @feature = stub('feature', name: 'Feature', tags: ["feature_tag"])
          Spinach.stubs(:find_step_definitions).returns(true)
          @scenario = stub(line: 4, tags: ["scenario_tag"])
          @feature.stubs(:scenarios).returns [@scenario]
        end

        it "runs matching scenario" do
          Spinach::TagsMatcher.expects(:match).with(["feature_tag", "scenario_tag"]).returns true
          Spinach::Runner::ScenarioRunner.expects(:new).with(@scenario).returns stub(run: true)

          @runner = Spinach::Runner::FeatureRunner.new(@feature)
          @runner.run
        end

        it "skips scenarios that do not match" do
          Spinach::TagsMatcher.expects(:match).with(["feature_tag", "scenario_tag"]).returns false
          Spinach::Runner::ScenarioRunner.expects(:new).never

          @runner = Spinach::Runner::FeatureRunner.new(@feature)
          @runner.run
        end

        it "doesn't accumulate tags from one scenario to the next" do
          next_scenario = stub(line: 14, tags: [])
          @feature.stubs(:scenarios).returns [@scenario, next_scenario]

          Spinach::TagsMatcher.expects(:match).with(["feature_tag", "scenario_tag"]).returns true
          Spinach::TagsMatcher.expects(:match).with(["feature_tag"]).returns false
          Spinach::Runner::ScenarioRunner.expects(:new).with(@scenario).returns stub(run: true)

          @runner = Spinach::Runner::FeatureRunner.new(@feature)
          @runner.run
        end
      end
    end
  end
end
