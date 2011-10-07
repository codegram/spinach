require_relative '../../test_helper'

describe Spinach::Runner::Feature do
  let(:filename) { 'feature/a_cool_feature.feature' }
  let(:feature) { Spinach::Runner::Feature.new(filename) }

  describe '#initialize' do
    it 'initializes the given filename' do
      feature.filename.must_equal filename
    end

    it 'initalizes the given scenario line' do
      @filename = 'feature/a_cool_feature.feature:12'
      @feature = Spinach::Runner::Feature.new(@filename)

      @feature.instance_variable_get(:@scenario_line).must_equal '12'
    end
  end

  describe '#feature' do
    it 'finds the feature given a feature name' do
      @feature = stub_everything
      feature.stubs(feature_name: 'A cool feature')

      Spinach.expects(:find_feature).with('A cool feature').returns(@feature)
      feature.feature
    end
  end

  describe '#data' do
    it 'returns the parsed data' do
      parsed_data = {name: 'A cool feature'}
      parser = stub(parse: parsed_data)
      Spinach::Parser.expects(:new).returns(parser)
      feature.data.must_equal parsed_data
    end
  end

  describe '#scenarios' do
    it 'returns the parsed scenarios' do
      feature.stubs(data: {'elements' => [1, 2, 3]})
      feature.scenarios.must_equal [1,2,3]
    end
  end

  describe '#run' do
    before do
      feature.stubs(data: {
        'name' => 'A cool feature',
        'elements' => [{'keyword'=>'Scenario', 'name'=>'Basic guess', 'line'=>6, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess II', 'line'=>12, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess III', 'line'=>18, 'description'=>'', 'type'=>'scenario'}]
      })
      feature.stubs(feature: stub_everything)
    end

    it 'calls the steps as expected' do
      seq = sequence('feature')
      feature.feature.expects(:run_hook).with(:before, kind_of(Hash))
      3.times do
        Spinach::Runner::Scenario.
          expects(:new).
          returns(stub_everything).
          in_sequence(seq)
      end
      feature.feature.expects(:run_hook).with(:after, kind_of(Hash))
      feature.run
    end

    it 'returns true if the execution succeeds' do
      Spinach::Runner::Scenario.any_instance.
        expects(run: true).times(3)
      feature.run.must_equal true
    end

    it 'returns false if the execution fails' do
      Spinach::Runner::Scenario.any_instance.
        expects(run: false).times(3)
      feature.run.must_equal false
    end

    it 'calls only the given scenario' do
      @filename = 'feature/a_cool_feature.feature:12'
      @feature = Spinach::Runner::Feature.new(@filename)
      @feature.stubs(data: {
        'name' => 'A cool feature',
        'elements' => [{'keyword'=>'Scenario', 'name'=>'Basic guess', 'line'=>6, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess II', 'line'=>12, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess III', 'line'=>18, 'description'=>'', 'type'=>'scenario'}]
      })
      @feature.stubs(feature: stub_everything)

      Spinach::Runner::Scenario.expects(:new).with(anything, anything, @feature.scenarios[1], anything).once.returns(stub_everything)
      @feature.run
    end
  end
end
