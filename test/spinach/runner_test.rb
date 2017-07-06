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

  describe '#init_reporters' do
    describe "when no reporter_classes option is passed in" do
      it 'inits the default reporter' do
        reporter = stub
        reporter.expects(:bind)
        Spinach::Reporter::Stdout.stubs(new: reporter)
        runner.init_reporters
      end
    end

    describe "when reporter_classes option is passed in" do
      it "inits the reporter classes" do
        config = Spinach::Config.new
        Spinach.stubs(:config).returns(config)
        config.reporter_classes = ["String"]
        reporter = stub
        reporter.expects(:bind)
        String.stubs(new: reporter)
        runner.init_reporters
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
        runner.init_reporters
      end
    end
  end

  describe '#run' do
    before(:each) do
      @feature_runner = stub
      filenames.each do |filename|
        Spinach::Parser.stubs(:open_file).with(filename).returns parser = stub
        parser.stubs(:parse).returns feature = Spinach::Feature.new
        Spinach::Runner::FeatureRunner.stubs(:new).
          with(feature, anything).
          returns(@feature_runner)
      end

      @feature_runner.stubs(:run).returns(true)
      runner.stubs(required_files: [])
    end

    it "inits reporters" do
      runner.expects(:init_reporters)
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

    describe 'when line set' do
      let(:filename) { 'features/cool_feature.feature' }
      let(:line) { 12 }
      let(:filenames) { ["#{filename}:#{line}"] }
      let(:runner) { Spinach::Runner.new(filenames) }

      it 'sets filename and lines_to_run on the feature' do
        @feature_runner = stub
        Spinach::Parser.stubs(:open_file).with(filename).returns parser = stub
        parser.stubs(:parse).returns feature = Spinach::Feature.new
        Spinach::Runner::FeatureRunner.stubs(:new).
          with(feature, anything).
          returns(@feature_runner)
        runner.stubs(required_files: [])
        @feature_runner.stubs(:run).returns(true)

        runner.run.must_equal true
        feature.filename.must_equal filename
        feature.lines_to_run.must_equal [line]
      end
    end

    describe "when lines set" do
      let(:filename) { "features/cool_feature.feature" }
      let(:line) { "12:24" }
      let(:filenames) { ["#{filename}:#{line}"] }
      let(:runner) { Spinach::Runner.new(filenames) }

      before(:each) do
        @feature_runner = stub
        Spinach::Parser.stubs(:open_file).with(filename).returns parser = stub
        parser.stubs(:parse).returns @feature = Spinach::Feature.new
        Spinach::Runner::FeatureRunner.stubs(:new).
          with(@feature, anything).
          returns(@feature_runner)
        runner.stubs(required_files: [])
      end

      it "sets filename and lines_to_run on the feature" do
        @feature_runner.stubs(:run).returns(true)
        runner.run.must_equal true
        @feature.filename.must_equal filename
        @feature.lines_to_run.must_equal line.split(":").map(&:to_i)
      end

      it "returns false if it fails" do
        @feature_runner.stubs(:run).returns(false)
        runner.run.must_equal false
      end

      it "breaks with a failure when fail fast set" do
        Spinach.config.stubs(:fail_fast).returns true
        @feature_runner.stubs(:run).returns(false)
        @feature_runner.expects(:run).never
        runner.run.must_equal false
      end

      it "does not break when success when fail fast set" do
        Spinach.config.stubs(:fail_fast).returns true
        @feature_runner.stubs(:run).returns(true)
        @feature_runner.expects(:run).returns true
        runner.run.must_equal true
      end
    end

    describe "when fail_fast set" do
      let(:feature_runners) { [ stub, stub ] }

      before(:each) do
        filenames.each_with_index do |filename, i|
          Spinach::Parser.stubs(:open_file).with(filename).returns parser = stub
          parser.stubs(:parse).returns feature = Spinach::Feature.new
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

      it "doesn't break when success" do
        feature_runners[0].stubs(:run).returns(true)
        feature_runners[1].expects(:run).returns true
        runner.run.must_equal true
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
    it 'requires the most deeply nested files first, then alphabetically' do
      FakeFS do
        FileUtils.mkdir_p('features/steps/a')
        FileUtils.mkdir_p('features/steps/z')
        ['features/steps/a.rb', 'features/steps/a/a.rb', 'features/steps/z.rb', 'features/steps/z/z.rb'].each do |f|
          FileUtils.touch(f)
        end
        runner.required_files.must_equal(['/features/steps/a/a.rb', '/features/steps/z/z.rb', '/features/steps/a.rb', '/features/steps/z.rb'])
      end
    end

    it 'requires environment files first' do
      runner.stubs(:step_definition_path).returns('steps')
      runner.stubs(:support_path).returns('support')
      Dir.stubs(:glob).returns(['/support/bar.rb', '/support/env.rb', '/support/quz.rb'])
      runner.stubs(:step_definition_files).returns(['/steps/bar.rb'])
      runner.required_files.must_equal(['/support/env.rb', '/support/bar.rb', '/support/quz.rb', '/steps/bar.rb'])
    end
  end

end
