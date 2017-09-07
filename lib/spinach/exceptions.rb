module Spinach
  # This class represents the exception raised when Spinach can't find a step
  # for a {FeatureSteps}.
  #
  class StepNotDefinedException < StandardError
    attr_reader :step

    # @param [Hash] step
    #   The missing step.
    #
    # @api public
    def initialize(step)
      @step = step
    end

    # @return [String]
    #   A custom message when scenario steps aren't found.
    #
    # @api public
    def message
      "Step '#{@step.name}' not found"
    end
  end

  # This class represents the exception raised when Spinach find a step
  # which claims to be pending for a {FeatureSteps}.
  #
  class StepPendingException < StandardError
    attr_reader :reason
    attr_accessor :step

    # @param [String] reason
    #   The reason why the step is set to pending
    #
    # @api public
    def initialize(reason)
      @reason = reason
    end

    # @return [String]
    #   A custom message when scenario steps are pending.
    #
    # @api public
    def message
      "Step '#{@step.name}' pending"
    end
  end

  # This class represents the exception raised when Spinach detects
  # that the around_scenario hook does not yield.
  #
  class HookNotYieldException < StandardError
    attr_reader :hook

    # @param [String] hook
    #   The hook which did not yield
    #
    # @api public
    def initialize(hook)
      @hook = hook
    end

    # @return [String]
    #   A custom message when a hook did not yield.
    #
    # @api public
    def message
      "#{@hook} hooks *must* yield"
    end
  end
end
