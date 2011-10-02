require 'minitest/spec'
MiniTest::Spec.new nil

module Spinach
  # The feature class is the class where all the features must inherit from.
  #
  class Feature
    include DSL
    include MiniTest::Assertions

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
