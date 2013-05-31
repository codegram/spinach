require_relative '../test_helper'

describe Spinach::Runner do
   let(:filenames) { %w{features/cool_feature.feature features/great_feature.feature} }
   let(:runner) { Spinach::Runner.new(filenames) }

  describe '#initialize' do
    it 'sets the filenames' do
      runner.filenames.must_equal filenames
    end

    describe 'step_definitions_path' do
      it 'sets a default' do
        runner.step_definitions_path.must_be_kind_of String
      end

      it 'can be overriden' do
        runner = Spinach::Runner.new(
          @filename, step_definitions_path: 'spinach/step_definitions'
        )
        runner.step_definitions_path.must_equal 'spinach/step_definitions'
      end
    end

    describe 'support_path' do
      it 'sets a default' do
        runner.support_path.must_be_kind_of String
      end

      it 'can be overriden' do
        runner = Spinach::Runner.new(
          @filename, support_path: 'spinach/environment'
        )
        runner.support_path.must_equal 'spinach/environment'
      end
    end
  end

  describe '#init_reporter' do
    describe "when no reporter_class option is passed in" do
      it 'inits the default reporter' do
        reporter = stub
        reporter.expects(:bind)
        Spinach::Reporter::Stdout.stubs(new: reporter)
        runner.init_reporter
      end
    end

    describe "when reporter_class option is passed in" do
      it "inits the reporter class" do
        config = Spinach::Config.new
        Spinach.stubs(:config).returns(config)
        config.reporter_class = "String"
        reporter = stub
        reporter.expects(:bind)
        String.stubs(new: reporter)
        runner.init_reporter
      end
    end

    describe "when backtrace is passed in" do
      it "inits with backtrace" do
        config = Spinach::Config.new
        Spinach.stubs(:config).returns(config)
        config.reporter_options = {backtrace: true}
        reporter = stub
        reporter.stubs(:bind)
        Spinach::Reporter::Stdout.expects(new: reporter).with(backtrace: true)
        runner.init_reporter
      end
    end
  end

  describe '#run' do
    before(:each) do
      @feature_runner = stub
      filenames.each do |filename|
        Spinach::Parser.stubs(:open_file).with(filename).returns parser = stub
        parser.stubs(:parse).returns feature = stub
        Spinach::Runner::FeatureRunner.stubs(:new).
          with(feature, anything).
          returns(@feature_runner)
      end

      @feature_runner.stubs(:run).returns(true)
      runner.stubs(required_files: [])
    end

    it "inits reporter" do
      runner.expects(:init_reporter)
      runner.run
    end

    it 'instantiates a new Feature and runs it with every file' do
      @feature_runner.stubs(:run).returns(true)
      runner.run.must_equal true
    end

    it 'returns false if it fails' do
      @feature_runner.stubs(:run).returns(false)
      runner.run.must_equal false
    end

    describe "when fail_fast set" do
      let(:feature_runners) { [ stub, stub ] }

      before(:each) do
        filenames.each_with_index do |filename, i|
          Spinach::Parser.stubs(:open_file).with(filename).returns parser = stub
          parser.stubs(:parse).returns feature = stub
          Spinach::Runner::FeatureRunner.stubs(:new).
            with(feature, anything).
            returns(feature_runners[i])
        end

        feature_runners[0].stubs(:run).returns(false)
        runner.stubs(required_files: [])
        Spinach.config.stubs(:fail_fast).returns true
      end

      it "breaks with a failure" do
        feature_runners[1].expects(:run).never
        runner.run.must_equal false
      end
    end
  end

  describe '#require_dependencies' do
    it 'requires support files and step definitions' do
      runner.stubs(
        required_files: ['a', 'b']
      )
      %w{a b}.each do |file|
        runner.expects(:require).with(file)
      end
      runner.require_dependencies
    end
  end

  describe '#required_files' do
    it 'requires environment files first' do
      runner.stubs(:step_definition_path).returns('steps')
      runner.stubs(:support_path).returns('support')
      Dir.stubs(:glob).returns(['/support/bar.rb', '/support/env.rb', '/support/quz.rb'])
      runner.stubs(:step_definition_files).returns(['/steps/bar.feature'])
      runner.required_files.must_equal(['/support/env.rb', '/support/bar.rb', '/support/quz.rb', '/steps/bar.feature'])
    end
  end

end
