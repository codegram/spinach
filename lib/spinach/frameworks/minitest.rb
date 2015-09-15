require 'minitest/spec'
MiniTest::Spec.new nil if defined?(MiniTest::Spec)
Spinach.config[:failure_exceptions] << MiniTest::Assertion

class Spinach::FeatureSteps
  include MiniTest::Assertions
  attr_accessor :assertions

  def initialize(*args)
    super *args
    self.assertions = 0
  end
end
