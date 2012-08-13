module Spinach
  # The feature class is the class which all the features must inherit from.
  #
  class FeatureSteps
    include DSL

    class << self
      # Registers the feature class for later use.
      #
      # @param [Class] base
      #   The host class.
      #
      # @api public
      def inherited(base)
        Spinach.feature_steps << base
      end

      alias_method :include_private, :include

      # Exposes the include method publicly so you can add more modules to it
      # due its plastic nature.
      #
      # @example
      #   Spinach::FeatureSteps.include Capybara::DSL
      def include(*args)
        include_private(*args)
      end
    end

    def before_each; end
    def after_each; end
  end
end
