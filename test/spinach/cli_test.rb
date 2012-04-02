require_relative '../test_helper'

describe Spinach::Cli do
  describe '#options' do
    it 'sets the default options' do
      cli = Spinach::Cli.new([])
      options = cli.options
      options[:reporter][:backtrace].must_equal false
    end

    describe 'backtrace' do
      %w{-b --backtrace}.each do |opt|
        it 'sets the backtrace if #{opt}' do
          cli = Spinach::Cli.new([opt])
          options = cli.options
          options[:reporter][:backtrace].must_equal true
        end
      end
    end

    describe 'features_path' do
      %w{-f --features_path}.each do |opt|
        it 'sets the given features_path' do
          config = Spinach::Config.new
          Spinach.stubs(:config).returns(config)
          cli = Spinach::Cli.new([opt,"custom_path"])
          cli.options
          config.features_path.must_equal 'custom_path'
        end
      end
    end

    describe 'tags' do
      %w{-t --tags}.each do |opt|
        it 'sets the given tag' do
          config = Spinach::Config.new
          Spinach.stubs(:config).returns(config)
          cli = Spinach::Cli.new([opt,'wip'])
          cli.options
          config.tags.must_equal [['wip']]
        end

        it 'sets OR-ed tags' do
          config = Spinach::Config.new
          Spinach.stubs(:config).returns(config)
          cli = Spinach::Cli.new([opt,'wip,javascript'])
          cli.options
          config.tags.must_equal [['wip', 'javascript']]
        end

        it 'adds ~wip by default' do
          config = Spinach::Config.new
          Spinach.stubs(:config).returns(config)
          cli = Spinach::Cli.new([opt,'javascript'])
          cli.options
          config.tags.must_equal [['~wip', 'javascript']]
        end
      end

      it 'sets AND-ed tags' do
        config = Spinach::Config.new
        Spinach.stubs(:config).returns(config)
        cli = Spinach::Cli.new(['-t','javascript', '-t', 'wip'])
        cli.options
        config.tags.must_equal [['~wip', 'javascript'],['wip']]
      end
    end

    describe 'generate' do
      %w{-g --generate}.each do |opt|
        it 'inits the generator if #{opt}' do
          Spinach::Generators.expects(:bind)
          cli = Spinach::Cli.new([opt])
          options = cli.options
        end
      end
    end

    describe "version" do
      %w{-v --version}.each do |opt|
        it "outputs the version" do
          cli = Spinach::Cli.new([opt])
          cli.expects(:exit)
          cli.expects(:puts).with(Spinach::VERSION)
          output = capture_stdout do
            cli.options
          end
        end
      end
    end

    describe 'config_path' do
      %w{-c --config_path}.each do |opt|
        it "sets the config path" do
          config = Spinach::Config.new
          Spinach.stubs(:config).returns(config)
          cli = Spinach::Cli.new([opt, 'config_file'])
          config.expects(:parse_from_file)
          cli.options
          config.config_path.must_equal 'config_file'
        end

        it "gets overriden by the other cli options" do
          config = Spinach::Config.new
          Spinach.stubs(:config).returns(config)
          YAML.stubs(:load_file).returns({features_path: 'my_path'})
          cli = Spinach::Cli.new(['-f', 'another_path', opt, 'config_file'])
          cli.options
          config.features_path.must_equal 'another_path'
        end
      end
    end

    describe 'undefined option' do
      %w{-lorem --ipsum}.each do |opt|
        it 'exits and outputs error message with #{opt}' do
          cli = Spinach::Cli.new([opt])
          cli.expects(:exit)
          cli.expects(:puts).with("Invalid option: #{opt}")
          options = cli.options
        end
      end
    end
  end

  describe '#init_reporter' do
    it 'inits the default reporter' do
      cli = Spinach::Cli.new([])
      reporter = stub
      reporter.expects(:bind)
      Spinach::Reporter::Stdout.stubs(new: reporter)
      cli.init_reporter
    end
  end

  describe '#run' do
    describe 'when a particular feature list is passed' do
      it 'runs the feature' do
        cli = Spinach::Cli.new(['features/some_feature.feature'])
        Spinach::Runner.expects(:new).with(['features/some_feature.feature']).
          returns(stub(:run))
        cli.run
      end
    end

    describe 'when no feature is passed' do
      it 'runs the feature' do
        cli = Spinach::Cli.new([])
        Dir.expects(:glob).with('features/**/*.feature').
          returns(['features/some_feature.feature'])
        Spinach::Runner.expects(:new).with(['features/some_feature.feature']).
          returns(stub(:run))
        cli.run
      end
    end
  end
end
