require 'minitest/unit'
require 'spinach'

Spinach.config[:failure_exceptions] << MiniTest::Assertion
Spinach::FeatureSteps.send(:include, MiniTest::Assertions)
