require 'minitest/spec'
MiniTest::Spec.new nil

module Spinach
  # The feature class is the class which all the features must inherit from.
  #
  class Feature
    include DSL
    include MiniTest::Assertions

    # Registers the feature class for later use.
    #
    # @param [Class] base
    #   The host class.
    #
    # @api public
    def self.inherited(base)
      Spinach.features << base
    end
  end
end

# Syntactic sugar. Define the "Feature do" syntax.
Object.send(:define_method, :Feature) do |name, &block|
  Class.new(Spinach::Feature) do
    feature name
    class_eval &block
  end
end
