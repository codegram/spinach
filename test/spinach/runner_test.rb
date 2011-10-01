require_relative '../test_helper'

describe Spinach::Runner do
  before do
    @filenames =
      %w{features/cool_feature.feature features/great_feature.feature}

    @runner = Spinach::Runner.new(@filenames)
  end
  describe "#initialize" do
    it "sets the filenames" do
      @runner.filenames.must_equal @filenames
    end
    describe "step_definitions_path" do
      it "sets a default" do
        @runner.step_definitions_path.must_be_kind_of String
      end
      it "can be overriden" do
        @runner = Spinach::Runner.new(
          @filename, step_definitions_path: 'spinach/step_definitions'
        )
        @runner.step_definitions_path.must_equal 'spinach/step_definitions'
      end
    end
    describe "support_path" do
      it "sets a default" do
        @runner.support_path.must_be_kind_of String
      end
      it "can be overriden" do
        @runner = Spinach::Runner.new(
          @filename, support_path: 'spinach/environment'
        )
        @runner.support_path.must_equal 'spinach/environment'
      end
    end
  end
  describe "#reporter" do
    it "returns a default reporter" do
      @runner.reporter.wont_equal nil
    end
  end
  describe "#run" do
    before do
      @feature = stub
      @runner.stubs(reporter: stub_everything)
      @filenames.each do |filename|
        Spinach::Runner::Feature.expects(:new).
          with(filename, anything).
          returns(@feature)
      end
    end
    it "instantiates a new Feature and runs it with every file" do
      @feature.stubs(run: true)
      @runner.run.must_equal true
    end
    it "returns false if it fails" do
      @feature.stubs(run: false)
      @runner.run
    end
  end
end
