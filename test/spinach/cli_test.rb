require_relative '../test_helper'

describe Spinach::Cli do
  describe '#run' do
    it 'gets the options and runs the features' do
      cli = Spinach::Cli.new(['features/some_feature.feature'])
      cli.stubs(:feature_files).returns(['features/some_feature.feature'])

      cli.expects(:options)
      Spinach::Runner.any_instance.expects(:run)
      cli.run
    end
  end

  describe '#options' do
    it 'sets the default options' do
      config = Spinach::Config.new
      Spinach.stubs(:config).returns(config)
      cli = Spinach::Cli.new([])
      options = cli.options
      config[:reporter_options].must_equal({})
    end

    it 'sets default tags' do
      config = Spinach::Config.new
      Spinach.stubs(:config).returns(config)
      cli = Spinach::Cli.new([])
      cli.options
      config[:tags].must_equal [['~wip']]
    end

    it 'sets default tags some are defined in config file' do
      in_current_dir do
        config = Spinach::Config.new
        config.config_path = "spinach.yml"
        File.open(config.config_path, "w") do |f|
          f.write <<-EOS
---
tags:
  - v1
  - - ~external
    - js
          EOS
        end
        Spinach.stubs(:config).returns(config)
        cli = Spinach::Cli.new([])
        cli.options
        config[:tags].must_equal [['~wip'], 'v1', ['~external', 'js']]
      end
    end

    describe 'backtrace' do
      %w{-b --backtrace}.each do |opt|
        it 'sets the backtrace if #{opt}' do
          config = Spinach::Config.new
          Spinach.stubs(:config).returns(config)
          cli = Spinach::Cli.new([opt])
          options = cli.options
          config[:reporter_options][:backtrace].must_equal true
        end
      end
    end

    describe 'reporter class' do
      %w{-r --reporter}.each do |opt|
        it 'sets the reporter class' do
          config = Spinach::Config.new
          Spinach.stubs(:config).returns(config)
          cli = Spinach::Cli.new([opt, "String"])
          options = cli.options
          config.reporter_class.must_equal 'String'
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

        it 'has precedence over tags specified in config file' do
          in_current_dir do
            config = Spinach::Config.new
            config.config_path = "spinach.yml"
            File.open(config.config_path, "w") do |f|
              f.write <<-EOS
---
tags:
  - v1
              EOS
            end
            Spinach.stubs(:config).returns(config)
            cli = Spinach::Cli.new([opt,'javascript'])
            cli.options
            config[:tags].must_equal [['~wip', 'javascript']]
          end
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

  describe '#feature_files' do
    describe 'when a particular feature list is passed' do
      describe 'the feature really exists' do
        it 'runs the feature' do
          cli = Spinach::Cli.new(['features/some_feature.feature'])
          File.stubs(:exists?).returns(true)
          cli.feature_files.must_equal ['features/some_feature.feature']
        end
      end

      describe 'it fails if the feature does not exist' do
        cli = Spinach::Cli.new(['features/some_feature.feature'])
        File.stubs(:exists?).returns(false)
        cli.expects(:fail!).with('features/some_feature.feature could not be found')

        cli.feature_files
      end
    end

    describe 'when a particular feature list is passed with line' do
      it 'returns the feature with the line number' do
        cli = Spinach::Cli.new(['features/some_feature.feature:10'])
        File.stubs(:exists?).returns(true)

        cli.feature_files.must_equal ['features/some_feature.feature:10']
      end
    end

    describe 'when no feature is passed' do
      it 'returns all the features' do
        cli = Spinach::Cli.new([])
        Dir.expects(:glob).with('features/**/*.feature')

        cli.feature_files
      end
    end

    describe 'when a folder is given' do
      it 'returns all feature files in the folder and subfolders' do
        cli = Spinach::Cli.new(['path/to/features'])

        File.stubs(:directory?).returns(true)
        Dir.expects(:glob).with('path/to/features/**/*.feature')

        cli.feature_files
      end
    end

    describe 'when multiple arguments are passed in' do
      describe 'a folder followed by file' do
        it 'returns the features in the folder and the particular file' do
          cli = Spinach::Cli.new(['path/to/features', 'some_feature.feature'])

          File.stubs(:directory?).returns(true)
          Dir.expects(:glob).with('path/to/features/**/*.feature')
            .returns(['several features'])

          File.stubs(:exists?).returns(true)

          cli.feature_files.must_equal ['several features', 'some_feature.feature']
        end
      end
    end
  end
end
