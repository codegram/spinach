module Spinach
  # This class represents the feature raised when Spniach can't find a class
  # for a feature.
  class FeatureNotFoundException < StandardError
    def initialize(options)
      @not_found_class = options.first
      @feature = options.last
    end

    # Returns a custom message when a feature class is not found.
    #
    def message
      "Could not find class for `#{@feature}` feature. Please create a #{@not_found_class}.rb file at #{Spinach.config[:step_definitions_path]}"
    end
  end

  # This class represents the step raised when Spinach can't find a step for a
  # Scenario.
  #
  class StepNotDefinedException < StandardError

    attr_reader :feature, :step

    def initialize(feature, step)
      @feature = feature
      @step = step
    end
  end
end
