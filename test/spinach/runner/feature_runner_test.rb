require_relative '../../test_helper'

describe Spinach::Runner::FeatureRunner do
  let(:feature) do
    stub('feature',
      name:             'Feature',
      scenarios:        [],
      background_steps: []
    )
  end
  subject { Spinach::Runner::FeatureRunner.new(feature) }

  describe '#initialize' do
    it 'initializes the given filename' do
      subject.feature.must_equal feature
    end
  end

  describe '#scenarios' do
    it 'delegates to the feature' do
      subject.feature.stubs(scenarios: [1,2,3])
      subject.scenarios.must_equal [1,2,3]
    end
  end

  describe '#run' do
    describe "when some steps don't exist" do
      it 'runs the hooks in order' do
        hooks = sequence('hooks')
        Spinach.hooks.expects(:run_before_feature).with(feature).in_sequence(hooks)
        Spinach.expects(:find_step_definitions).returns(false).in_sequence(hooks)
        Spinach.hooks.expects(:run_after_feature).with(feature).in_sequence(hooks)

        subject.run
      end
    end

    describe 'when all the steps exist' do
      before do
        @scenarios = [
          scenario         = stub(tags: []),
          another_scenario = stub(tags: [])
        ]
        @feature = stub('feature',
          name:                "Feature",
          tags:                [],
          scenarios:           @scenarios,
          run_every_scenario?: true
        )
        Spinach.stubs(:find_step_definitions).returns(true)
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
        describe "without config option fail_fast set" do
          it 'runs the scenarios and returns false' do
            @scenarios.each do |scenario|
              runner = stub(run: false)
              Spinach::Runner::ScenarioRunner.expects(:new).with(scenario).returns runner
            end

            @runner.run.must_equal false
          end
        end

        describe "with config option fail_fast set" do
          let(:runners) { [ stub('runner1', run: false), stub('runner2') ] }

          before(:each) do
            Spinach.config.stubs(:fail_fast).returns(true)
            @scenarios.each_with_index do |scenario, i|
              Spinach::Runner::ScenarioRunner.stubs(:new).with(scenario).returns runners[i]
            end
          end

          it "breaks with fail_fast config option" do
            runners[1].expects(:run).never
            @runner.run.must_equal(false)
          end
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

    describe "when only running specific lines" do
      before do
        @scenarios = [
          stub(tags: [], lines: (4..8).to_a),
          stub(tags: [], lines: (12..15).to_a),
        ]
        @feature = stub('feature',
          name:                'Feature',
          tags:                [],
          scenarios:           @scenarios,
          run_every_scenario?: false,
        )
        Spinach.stubs(:find_step_definitions).returns(true)
      end

      it "runs exactly matching scenario" do
        Spinach::Runner::ScenarioRunner.expects(:new).with(@scenarios[1]).returns stub(run: true)
        @feature.stubs(:lines_to_run).returns([12])
        @runner = Spinach::Runner::FeatureRunner.new(@feature)
        @runner.run
      end

      it "runs no scenario and returns false" do
        Spinach::Runner::ScenarioRunner.expects(:new).never
        @feature.stubs(:lines_to_run).returns([3])
        @runner = Spinach::Runner::FeatureRunner.new(@feature)
        @runner.run
      end

      it "runs matching scenario" do
        Spinach::Runner::ScenarioRunner.expects(:new).with(@scenarios[0]).returns stub(run: true)
        @feature.stubs(:lines_to_run).returns([8])
        @runner = Spinach::Runner::FeatureRunner.new(@feature)
        @runner.run
      end

      it "runs last scenario" do
        Spinach::Runner::ScenarioRunner.expects(:new).with(@scenarios[1]).returns stub(run: true)
        @feature.stubs(:lines_to_run).returns([15])
        @runner = Spinach::Runner::FeatureRunner.new(@feature)
        @runner.run
      end
    end

    describe "when running for specific tags configured" do

      describe "with feature" do
        before do
          @scenario = stub(tags: [])
          @feature = stub('feature',
            name:                'Feature',
            tags:                ["feature_tag"],
            scenarios:           [@scenario],
            run_every_scenario?: true,
          )
          Spinach.stubs(:find_step_definitions).returns(true)
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
          @scenario = stub(tags: ["scenario_tag"])
          @feature = stub('feature',
            name:                'Feature',
            tags:                ["feature_tag"],
            scenarios:           [@scenario],
            run_every_scenario?: true,
          )
          Spinach.stubs(:find_step_definitions).returns(true)
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
          next_scenario = stub(tags: [])
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
