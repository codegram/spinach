module Spinach
  # The feature class is the class which all the features must inherit from.
  #
  class FeatureSteps
    include DSL

    # Registers the feature class for later use.
    #
    # @param [Class] base
    #   The host class.
    #
    # @api public
    def self.inherited(base)
      Spinach.feature_steps << base
    end
  end
end

# Syntactic sugar. Define the "Feature do" syntax.
Object.send(:define_method, :Feature) do |name, &block|
  Class.new(Spinach::FeatureSteps) do
    feature name
    class_eval &block
  end
end
