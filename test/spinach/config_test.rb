require_relative '../test_helper'

describe Spinach::Config do
  describe "#step_definitions_path" do
    it "returns a default" do
      (Spinach.config[:step_definitions_path].kind_of? String).must_equal true
    end
    it "can be overwritten" do
      Spinach.config[:step_definitions_path] = 'steps'
      Spinach.config[:step_definitions_path].must_equal 'steps'
    end
  end
end
