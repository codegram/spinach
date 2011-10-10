require 'hooks'

module Spinach
  # Spinach DSL aims to provide an easy way to define steps and hooks into your
  # feature classes.
  #
  module DSL
    # @param [Class] base
    #   The host class.
    #
    # @api public
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend ClassMethods
        include Hooks

        define_hook :before_scenario
        define_hook :after_scenario
        define_hook :before_step
        define_hook :after_step

      end
    end

    # Class methods to extend the host class.
    #
    module ClassMethods
      # The feature name.
      attr_reader :feature_name
      # Defines an action to perform given a particular step literal.
      #
      # @param [String] step
      #   The step name.
      #
      # @param [Proc] block
      #   Action to perform in that step.
      #
      # @example
      #   class MyFeature < Spinach::FeatureSteps
      #     When "I go to the toilet" do
      #       @sittin_on_the_toilet.must_equal true
      #     end
      #   end
      #
      # @api public
      def Given(step, &block)
        define_method(Spinach::Support.underscore(step), &block)
      end

      alias_method :When, :Given
      alias_method :Then, :Given
      alias_method :And, :Given
      alias_method :But, :Given

      # Sets the feature name.
      #
      # @param [String] name
      #   The name.
      #
      # @example
      #   class MyFeature < Spinach::FeatureSteps
      #     feature "Satisfy needs"
      #   end
      #
      # @api public
      def feature(name)
        @feature_name = name
      end
    end

    # Instance methods to include in the host class.
    #
    module InstanceMethods
      # Executes a given step.
      #
      # @param [String] step
      #   The step name to execute.
      #
      # @return [String]
      #   The file and line where the step was defined.
      #
      # @api public
      def execute_step(step)
        step = Spinach::Support.underscore(step)
        location = nil
        if self.respond_to?(step)
          location = method(step).source_location
          self.send(step)
        else
          raise Spinach::StepNotDefinedException.new(self, step)
        end
        location
      end

      # @return [String]
      #   The feature name.
      def name
        self.class.feature_name
      end
    end
  end
end
