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
            @reporter.send(abstract_method, stub_everything)
          }.must_raise RuntimeError
        end
      end
    end

    describe "#step" do
      it "raises an error" do
        Proc.new{
          @reporter.step(stub_everything, :success)
        }.must_raise RuntimeError
      end
    end

    describe "#end" do
      it "raises an error" do
        Proc.new{
          @reporter.end(0)
        }.must_raise RuntimeError
      end
    end
  end

end
