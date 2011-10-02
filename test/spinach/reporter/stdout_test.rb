# encoding: utf-8

require_relative '../../test_helper'

describe Spinach::Reporter::Stdout do
  before do
    @reporter = Spinach::Reporter::Stdout.new
  end

  describe "#feature" do
    it "outputs a feature name" do
      out = capture_stdout do
        @reporter.feature "User authentication"
      end
      out.string.must_match /Feature:.*User authentication/
    end
  end

  describe "#scenario" do
    it "outputs a scenario name" do
      out = capture_stdout do
        @reporter.scenario "User logs in"
      end
      out.string.must_match /Scenario:.*User logs in/
    end
  end

  describe "#step" do
    before do
      @feature = stubs(name: "Some cool feature")
    end
    describe "when succeeding" do
      it "outputs the step name" do
        out = capture_stdout do
          @reporter.step "Given", "I say goodbye", :success
        end
        out.string.must_include "✔"
        out.string.must_match /Given.*I say goodbye/
      end
    end

    describe "when undefined" do
      it "outputs the step name with a question mark" do
        out = capture_stdout do
          @reporter.step "Given", "I say goodbye", :undefined_step
        end
        out.string.must_include "?"
        out.string.must_match /Given.*I say goodbye/
      end
    end

    describe "when failing" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step "Given", "I say goodbye", :failure
        end
        out.string.must_include "✘"
        out.string.must_match /Given.*I say goodbye/
      end
    end

    describe "when failing" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step "Given", "I say goodbye", :error
        end
        out.string.must_include "!"
        out.string.must_match /Given.*I say goodbye/
      end
    end

    describe "when skipping" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step "Given", "I say nothing", :skip
        end
        out.string.must_include "~"
        out.string.must_match /Given.*I say nothing/
      end
    end
  end

  describe "#end" do
    it "outputs a blank line" do
      out = capture_stdout do
        @reporter.end
      end
      out.string.must_include "\n"
    end
  end

  describe "#error_summary" do
    before do
      make_error = proc do |message|
        stub(
          message: message,
          backtrace: ["foo:1", "bar:2"]
        )
      end

      make_scenario = proc do |name|
        stub(
          feature_name: name,
          feature: stub_everything,
          name: name
        )
      end

      @errors = [
        [make_error.('omg'), "some_file", "3", make_scenario.('feature')],
        [make_error.('wtf'), "other_file", "9", make_scenario.('feature')],
      ]

    end

    it "outputs an error summary" do
      out = capture_stdout do
        @reporter.error_summary(@errors)
      end
      out.string.must_include "omg"
      out.string.must_include "some_file"
      out.string.must_include "(line 3)"
      out.string.must_include "wtf"
      out.string.must_include "other_file"
      out.string.must_include "(line 9)"
      out.string.wont_include "foo:1"
      out.string.wont_include "bar:2"
    end
    it "outputs an error summary with backtrace" do
      @reporter.options[:backtrace] = true
      out = capture_stdout do
        @reporter.error_summary(@errors)
      end
      out.string.must_include "omg"
      out.string.must_include "some_file"
      out.string.must_include "(line 3)"
      out.string.must_include "wtf"
      out.string.must_include "other_file"
      out.string.must_include "(line 9)"
      out.string.must_include "foo:1"
      out.string.must_include "bar:2"
    end
  end
end
