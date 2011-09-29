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
      out.string.must_include "\nFeature: User authentication"
    end
  end

  describe "#scenario" do
    it "outputs a scenario name" do
      out = capture_stdout do
        @reporter.scenario "User logs in"
      end
      out.string.must_include "  Scenario: User logs in"
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
        out.string.must_include "Given I say goodbye"
      end
    end

    describe "when undefined" do
      it "outputs the step name with a question mark" do
        out = capture_stdout do
          @reporter.step "Given", "I say goodbye", :undefined_step,
            Spinach::StepNotDefinedException.new(
              @feature, "Given", "I say goodbye")
        end
        out.string.must_include "?"
        out.string.must_include "Given I say goodbye"
      end
    end

    describe "when failing" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step "Given", "I say goodbye", :failure,
            MiniTest::Assertion.new
        end
        out.string.must_include "✘"
        out.string.must_include "Given I say goodbye"
      end
    end

    describe "when failing" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step "Given", "I say goodbye", :error,
            RuntimeError.new
        end
        out.string.must_include "!"
        out.string.must_include "Given I say goodbye"
      end
    end

    describe "when skipping" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step "Given", "I say nothing", :skip
        end
        out.string.must_include "~"
        out.string.must_include "Given I say nothing"
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
end
