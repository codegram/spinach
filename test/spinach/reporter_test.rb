# encoding: utf-8
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

    describe "#end" do
      it "raises an error" do
        Proc.new{
          @reporter.end
        }.must_raise RuntimeError
      end
    end
  end

end
