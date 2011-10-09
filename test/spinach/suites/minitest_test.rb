require_relative '../../test_helper'

describe "minitest suite" do
  before do
    require_relative '../../../lib/spinach/suites/minitest'
  end

  it "adds MiniTest::Assertion into the failure exceptions" do
    Spinach.config[:failure_exceptions].must_include MiniTest::Assertion
  end

  it "extends the FeatureSteps class with MiniTest DSL" do
    Spinach::FeatureSteps.ancestors.must_include MiniTest::Assertions
  end
end
