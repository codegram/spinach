require_relative '../../test_helper'

describe Spinach::Runner::FeatureRunner do
  let(:filename) { 'feature/a_cool_feature.feature' }
  subject{ Spinach::Runner::FeatureRunner.new(filename) }

  describe '#initialize' do
    it 'initializes the given filename' do
      subject.filename.must_equal filename
    end

    it 'initalizes the given scenario line' do
      @filename = 'feature/a_cool_feature.feature:12'
      @feature = Spinach::Runner::FeatureRunner.new(@filename)

      @feature.instance_variable_get(:@scenario_line).must_equal '12'
    end
  end

  describe '#data' do
    it 'returns the parsed data' do
      parsed_data = {name: 'A cool feature'}
      parser = stub(parse: parsed_data)
      Spinach::Parser.expects(:open_file).returns(parser)
      subject.data.must_equal parsed_data
    end
  end

  describe '#scenarios' do
    it 'returns the parsed scenarios' do
      subject.stubs(data: {'elements' => [1, 2, 3]})
      subject.scenarios.must_equal [1,2,3]
    end
  end

  describe '#run' do
    before do
      subject.stubs(data: {
        'name' => 'A cool feature',
        'elements' => [{'keyword'=>'Scenario', 'name'=>'Basic guess', 'line'=>6, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess II', 'line'=>12, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess III', 'line'=>18, 'description'=>'', 'type'=>'scenario'}]
      })
      subject.stubs(feature: stub_everything)
    end

    it 'calls the steps as expected' do
      Spinach.expects(:find_feature_steps).returns(true)
      seq = sequence('feature')
      3.times do
        Spinach::Runner::ScenarioRunner.
          expects(:new).
          returns(stub_everything).
          in_sequence(seq)
      end
      subject.run
    end

    it 'returns true if the execution succeeds' do
      Spinach.expects(:find_feature_steps).returns(true)
      Spinach::Runner::ScenarioRunner.any_instance.
        expects(run: true).times(3)
      subject.run.must_equal true
    end

    it 'returns false if the execution fails' do
      Spinach.expects(:find_feature_steps).returns(true)
      Spinach::Runner::ScenarioRunner.any_instance.
        expects(run: false).times(3)
      subject.run.must_equal false
    end

    it 'calls only the given scenario' do
      Spinach.expects(:find_feature_steps).returns(true)
      @filename = 'feature/a_cool_feature.feature:12'
      @feature = Spinach::Runner::FeatureRunner.new(@filename)
      @feature.stubs(data: {
        'name' => 'A cool feature',
        'elements' => [{'keyword'=>'Scenario', 'name'=>'Basic guess', 'line'=>6, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess II', 'line'=>12, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess III', 'line'=>18, 'description'=>'', 'type'=>'scenario'}]
      })

      Spinach::Runner::ScenarioRunner.expects(:new).with(anything, @feature.scenarios[1], anything).once.returns(stub_everything)
      @feature.run
    end

    it "fires a hook if the feature is not defined" do
      data = stub_everything
      Spinach.expects(:find_feature_steps).returns(false)
      subject.stubs(:data).returns(data)
      not_found_called = false
      Spinach.hooks.on_undefined_feature do |data|
        not_found_called = data
      end
      subject.run
      not_found_called.must_equal data
    end
  end
end
