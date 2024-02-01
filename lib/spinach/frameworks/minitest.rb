require 'minitest/spec'

if defined? MiniTest::Spec
  MiniTest::Spec.new nil
elsif defined? Minitest::Spec
  Minitest::Spec.new nil
end

if defined? MiniTest::Assertion
  Spinach.config[:failure_exceptions] << MiniTest::Assertion

  class Spinach::FeatureSteps
    include MiniTest::Assertions
    attr_accessor :assertions
  
    def initialize(*args)
      super *args
      self.assertions = 0
    end
  end 
elsif defined? Minitest::Assertion
  Spinach.config[:failure_exceptions] << Minitest::Assertion

  class Spinach::FeatureSteps
    include Minitest::Assertions
    attr_accessor :assertions
  
    def initialize(*args)
      super *args
      self.assertions = 0
    end
  end
end

