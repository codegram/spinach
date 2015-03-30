require_relative '../../test_helper'

describe "minitest framework" do
  before do
    require_relative '../../../lib/spinach/frameworks/minitest'
  end

  it "adds MiniTest::Assertion into the failure exceptions" do
    Spinach.config[:failure_exceptions].must_include MiniTest::Assertion
  end

  it "extends the FeatureSteps class with MiniTest DSL" do
    Spinach::FeatureSteps.ancestors.must_include MiniTest::Assertions
  end

  it "makes FeatureSteps respond to 'assertions'" do
    Spinach::FeatureSteps.new.must_respond_to :assertions
  end

  it "initializes FeatureSteps' assertions with zero" do
    Spinach::FeatureSteps.new.assertions.must_equal 0
  end
end
