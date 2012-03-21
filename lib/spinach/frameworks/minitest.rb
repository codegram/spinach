require 'minitest/spec'
MiniTest::Spec.new nil if defined?(MiniTest::Spec)
Spinach.config[:failure_exceptions] << MiniTest::Assertion
Spinach::FeatureSteps.include MiniTest::Assertions
