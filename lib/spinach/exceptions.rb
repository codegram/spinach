module Spinach
  # This class represents the exception raised when Spinach can't find a class
  # for a feature.
  #
  class FeatureNotFoundException < StandardError
    # @param [Array] options
    #   An array consisting of the missing class and the feature.
    #
    # @api pulic
    def initialize(options)
      @missing_class, @feature = options
    end

    # @return [String]
    #   A custom message when a feature class is not found.
    #
    # @api public
    def message
      "Could not find class for `#{@feature}` feature. Please create a #{@missing_class}.rb file at #{Spinach.config[:step_definitions_path]}"
    end
  end

  # This class represents the exception raised when Spinach can't find a step
  # for a {Scenario}.
  #
  class StepNotDefinedException < StandardError
    attr_reader :feature, :step

    # @param [Feature] feature
    #   The container feature.
    #
    # @param [Hash] step
    #   The missing step.
    #
    # @api pulic
    def initialize(feature, step)
      @feature = feature
      @step = step
    end
  end
end
