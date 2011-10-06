# encoding: utf-8
require_relative '../test_helper'

describe Spinach::Reporter do
  before do
    @options = {
      backtrace: true
    }
    @reporter = Spinach::Reporter.new(@options)
  end

  describe "#initialize" do
    it "initializes the option hash" do
    end
  end

  describe "#options" do
    it "returns the options passed to the reporter" do
      @reporter.options[:backtrace].must_equal true
    end
  end

  describe "#current_feature" do
    it "returns nil by default" do
      @reporter.current_feature.must_equal nil
    end
  end

  describe "#current_scenario" do
    it "returns nil by default" do
      @reporter.current_feature.must_equal nil
    end
  end

  %w{undefined_steps failed_steps error_steps}.each do |errors|
    describe "##{errors}" do
      it "returns an empty array by default" do
        @reporter.send(errors).must_be_empty
      end
    end
  end
end
