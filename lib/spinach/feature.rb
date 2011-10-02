require 'minitest/spec'
require 'hooks'
MiniTest::Spec.new nil

module Spinach
  # The feature class is the class where all the features must inherit from.
  #
  class Feature
    include DSL
    include MiniTest::Assertions
    include Hooks

    define_hook :before
    define_hook :after
    define_hook :before_scenario
    define_hook :after_scenario
    define_hook :before_step
    define_hook :after_step

    def self.inherited(base)
      Spinach.features << base
    end
  end
end

# Syntax sugar. Define the "Feature do" syntax
#
Object.send(:define_method, :Feature) do |name, &block|
  Class.new(Spinach::Feature) do
    feature name
    class_eval &block
  end
end
