require_relative '../../test_helper'

describe Spinach::Runner::Feature do
  before do
    @filename = 'feature/a_cool_feature.feature'
    @reporter = stub_everything
    @feature = Spinach::Runner::Feature.new(@filename, @reporter)
  end

  describe '#initialize' do
    it 'initializes the given filename' do
      @feature.filename.must_equal @filename
    end

    it 'initializes the given reporter' do
      @feature.reporter.must_equal @reporter
    end

    it 'initalizes the given scenario line' do
      @filename = 'feature/a_cool_feature.feature:12'
      @feature = Spinach::Runner::Feature.new(@filename, @reporter)

      @feature.instance_variable_get(:@scenario_line).must_equal '12'
    end
  end

  describe '#feature' do
    it 'finds the feature given a feature name' do
      feature = stub_everything
      @feature.stubs(feature_name: 'A cool feature')
      Spinach.expects(:find_feature).with('A cool feature').returns(feature)
      @feature.feature
    end
  end

  describe '#data' do
    it 'returns the parsed data' do
      parsed_data = {'name' => 'A cool feature'}
      parser = stub(:parse => parsed_data)
      Spinach::Parser.expects(:new).returns(parser)
      @feature.data.must_equal parsed_data
    end
  end

  describe '#scenarios' do
    it 'returns the parsed scenarios' do
      @feature.stubs(data: {'elements' => [1, 2, 3]})
      @feature.scenarios.must_equal [1,2,3]
    end
  end

  describe '#run' do
    before do
      @feature.stubs(data: {
        'name' => 'A cool feature',
        'elements' => [{'keyword'=>'Scenario', 'name'=>'Basic guess', 'line'=>6, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess II', 'line'=>12, 'description'=>'', 'type'=>'scenario'},
                       {'keyword'=>'Scenario', 'name'=>'Basic guess III', 'line'=>18, 'description'=>'', 'type'=>'scenario'}]
      })
      @feature.stubs(feature: stub_everything)
    end

    it 'reports' do
      Spinach::Runner::Scenario.stubs(new: stub_everything)

      @reporter.expects(:feature).with('A cool feature')
      @feature.run
    end

    it 'calls the steps as expected' do
      seq = sequence('feature')
      3.times do
        @feature.feature.expects(:before).in_sequence(seq)
        Spinach::Runner::Scenario.
          expects(:new).
          returns(stub_everything).
          in_sequence(seq)
        @feature.feature.expects(:after).in_sequence(seq)
      end
      @feature.run
    end

    it "returns true if the execution succeeds" do
      @feature.stubs(reporter: stub_everything)
      Spinach::Runner::Scenario.any_instance.
        expects(run: nil).times(3)
      @feature.run.must_equal true
    end

    it "returns false if the execution fails" do
      @feature.stubs(reporter: stub_everything)
      Spinach::Runner::Scenario.any_instance.
        expects(run: stub_everything).times(3)
      @feature.run.must_equal false
    end

    it 'calls only the given scenario' do
      @filename = 'feature/a_cool_feature.feature:12'
      @feature = Spinach::Runner::Feature.new(@filename, @reporter)
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

    it "calls an error summary if there are any failures" do
      failure = stub('failure')
      scenario = stub(run: failure)
      Spinach::Runner::Scenario.stubs(:new).returns scenario

      @reporter.expects(:error_summary).with [failure, failure, failure]

      @feature.run
    end
  end
end
