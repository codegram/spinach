module Spinach
  # This class represents the exception raised when Spinach can't find a step
  # for a {FeatureSteps}.
  #
  class StepNotDefinedException < StandardError
    attr_reader :feature, :step

    # @param [Hash] step
    #   The missing step.
    #
    # @api pulic
    def initialize(step)
      @step = step
    end

    # @return [String]
    #   A custom message when scenario steps aren't found.
    #
    # @api public
    def message
      "Step '#{@step}' not found"
    end
  end
end
