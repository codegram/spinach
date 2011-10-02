# encoding: utf-8

require_relative '../../test_helper'

describe Spinach::Reporter::Stdout do
  before do
    @reporter = Spinach::Reporter::Stdout.new
  end

  describe "#feature" do
    it "outputs a feature name" do
      out = capture_stdout do
        @reporter.feature({'name' => 'User authentication'})
      end
      out.string.must_match /Feature:.*User authentication/
    end
  end

  describe "#scenario" do
    it "outputs a scenario name" do
      out = capture_stdout do
        @reporter.scenario({'name' => "User logs in"})
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
          @reporter.step({
            'keyword' => 'Given',
            'name' => "I say goodbye"
          }, :success)
        end
        out.string.must_include "✔"
        out.string.must_match /Given.*I say goodbye/
      end
    end

    describe "when undefined" do
      it "outputs the step name with a question mark" do
        out = capture_stdout do
          @reporter.step({
            'keyword' => 'Given',
            'name' => "I say goodbye"
          }, :undefined_step)
        end
        out.string.must_include "?"
        out.string.must_match /Given.*I say goodbye/
      end
    end

    describe "when failing" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step({
            'keyword' => 'Given',
            'name' => "I say goodbye"
          }, :failure)
        end
        out.string.must_include "✘"
        out.string.must_match /Given.*I say goodbye/
      end
    end

    describe "when failing" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step({
            'keyword' => 'Given',
            'name' => "I say goodbye"
          }, :error)
        end
        out.string.must_include "!"
        out.string.must_match /Given.*I say goodbye/
      end
    end

    describe "when skipping" do
      it "outputs the step name with a failure mark" do
        out = capture_stdout do
          @reporter.step({
            'keyword' => 'Given',
            'name' => "I say nothing"
          }, :skip)
        end
        out.string.must_include "~"
        out.string.must_match /Given.*I say nothing/
      end
    end
  end

  describe "#end" do
    it "outputs a blank line" do
      out = capture_stdout do
        @reporter.end(true)
      end
      out.string.must_include "\n"
    end
  end

end
