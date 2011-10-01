require_relative '../test_helper'

describe Spinach::Cli do
  describe "#options" do
    it "defaults" do
      cli = Spinach::Cli.new([])
      options = cli.options
      options[:reporter][:backtrace].must_equal false
    end
    describe "backtrace" do
      %w{-b --backtrace}.each do |opt|
        it "sets the backtrace if #{opt}" do
          cli = Spinach::Cli.new([opt])
          options = cli.options
          options[:reporter][:backtrace].must_equal true
        end
      end
    end
  end
  describe "#init_reporter" do
    it "inits the default reporter" do
      Spinach.config.default_reporter.wont_equal nil
    end
  end
  describe "#run" do
    describe "when a particular feature list is passed" do
      it "runs the feature" do
        cli = Spinach::Cli.new(['features/some_feature.feature'])
        Spinach::Runner.expects(:new).with(['features/some_feature.feature']).
          returns(stub(:run))
        cli.run
      end
    end
    describe "when no feature is passed" do
      it "runs the feature" do
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
