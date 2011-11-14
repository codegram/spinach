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

    describe 'backtrace' do
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
