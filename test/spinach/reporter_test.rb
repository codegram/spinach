require_relative '../test_helper'

describe Spinach::Reporter do
  describe "abstract methods" do
    before do
      @reporter = Spinach::Reporter.new
    end
    %w{feature scenario}.each do |abstract_method|
      describe "#{abstract_method}" do
        it "raises an error" do
          Proc.new{
            @reporter.send(abstract_method, "arbitrary name")
          }.must_raise RuntimeError
        end
      end
    end
    describe "#step" do
      it "raises an error" do
        Proc.new{
          @reporter.step("arbitrary name", :success)
        }.must_raise RuntimeError
      end
    end
  end
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
        out.string.must_include "\tScenario: User logs in"
      end
    end
    describe "#step" do
      describe "when succeeding" do
        it "outputs the step name" do
          out = capture_stdout do
            @reporter.step "Given I say goodbye", :success
          end
          out.string.must_include "\t\tGiven I say goodbye"
        end
      end
      describe "when failing" do
        it "outputs the step name with an F!" do
          out = capture_stdout do
            @reporter.step "Given I say goodbye", :failure
          end
          out.string.must_include "\t\tF! Given I say goodbye"
        end
      end
    end
  end
end
