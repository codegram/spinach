# encoding: utf-8

require_relative '../../test_helper'

describe Spinach::Reporter::Stdout do
  before do
    @out = StringIO.new
    @error = StringIO.new
    @reporter = Spinach::Reporter::Stdout.new(@out, @error)
  end
  describe "#before_feature_run" do
    it "outputs the feature" do
      @reporter.before_feature_run('name' => "A cool feature")
      @out.string.must_include "Feature"
      @out.string.must_include "A cool feature"
    end
  end
  describe "#before_scenario_run" do
    it "outputs the scenario" do
      @reporter.before_scenario_run('name' => "Arbitrary scenario")
      @out.string.must_include "Scenario"
      @out.string.must_include "Arbitrary scenario"
    end
  end
  describe "#after_scenario_run" do
    describe "in case of error" do
      before do
        @exception = stub_everything
        @reporter.scenario_error = @exception
      end
      it "reports the full error" do
        @reporter.expects(:report_error).with(@exception, :full)
        @reporter.after_scenario_run('name' => "Arbitrary scenario")
      end
      it "reports the full error" do
        @reporter.stubs(:report_error)
        @reporter.after_scenario_run('name' => "Arbitrary scenario")
        @reporter.scenario_error.must_equal nil
      end
    end
  end
end
