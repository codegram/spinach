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
      #   These 3 examples are equivalent:
      #
      #   class MyFeature < Spinach::FeatureSteps
      #     When "I go to the toilet" do
      #       @sittin_on_the_toilet.must_equal true
      #     end
      #   end
      #
      #   class MyFeature < Spinach::FeatureSteps
      #     step "I go to the toilet" do
      #       @sittin_on_the_toilet.must_equal true
      #     end
      #   end
      #
      #   class MyFeature < Spinach::FeatureSteps
      #     def i_go_to_the_toilet
      #       @sittin_on_the_toilet.must_equal true
      #     end
      #   end
      #
      # @api public
      def step(step, &block)
        define_method(Spinach::Support.underscore(step), &block)
      end

      alias_method :Given, :step
      alias_method :When, :step
      alias_method :Then, :step
      alias_method :And, :step
      alias_method :But, :step

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
      # @api public
      def execute(step)
        underscored_step = Spinach::Support.underscore(step.name)
        if self.respond_to?(underscored_step)
          self.send(underscored_step)
        else
          raise Spinach::StepNotDefinedException.new(step)
        end
      end

      # Gets current step source location.
      #
      # @param [String] step
      #   The step name to execute.
      #
      # @return [String]
      #   The file and line where the step was defined.
      def step_location_for(step)
        underscored_step = Spinach::Support.underscore(step)
        location = method(underscored_step).source_location if self.respond_to?(underscored_step)
      end

      # @return [String]
      #   The feature name.
      def name
        self.class.feature_name
      end

      # Raises an exception that defines the current step as a pending one.
      #
      # @api public
      #
      # @param [String] reason
      #   The reason why the step is set to pending
      #
      # @raise [Spinach::StepPendingException]
      #   Raising the exception tells the scenario runner the current step is
      #   pending.
      def pending(reason)
        raise Spinach::StepPendingException.new(reason)
      end

    end
  end
end
