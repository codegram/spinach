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

  describe '#run' do
    before do
      @feature_runner = stub
      filenames.each do |filename|
        Spinach::Parser.expects(:open_file).with(filename).returns parser = stub
        parser.stubs(:parse).returns feature = stub
        Spinach::Runner::FeatureRunner.expects(:new).
          with(feature, anything).
          returns(@feature_runner)
      end

      runner.stubs(required_files: [])
    end

    it 'instantiates a new Feature and runs it with every file' do
      @feature_runner.stubs(:run).returns(true)
      runner.run.must_equal true
    end

    it 'returns false if it fails' do
      @feature_runner.stubs(:run).returns(false)
      runner.run.must_equal false
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
