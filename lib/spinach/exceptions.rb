module Spinach
  # This class represents the exception raised when Spinach can't find a class
  # for a feature.
  #
  class FeatureStepsNotFoundException < StandardError
    # @param [Array] options
    #   An array consisting of the missing class and the feature.
    #
    # @api pulic
    def initialize(options)
      @missing_class, @feature = options
    end

    # @return [String]
    #   A custom message when feature steps aren't found.
    #
    # @api public
    def message
      [%Q{Could not find steps for `#{@feature}` feature.
      Please create the file #{Spinach::Support.underscore(@missing_class)}.rb
      at #{Spinach.config[:step_definitions_path]}, with:}.gsub(/^\s{6,7}/, ''),
      %Q{Feature "#{@feature}" do
         #
         # define your steps here
         #
      end}.gsub(/^\s{6,7}/, '')].join("\n\n")
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
