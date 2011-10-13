require 'capybara'
require 'capybara/dsl'
require_relative 'feature_steps'

module Spinach
  class FeatureSteps
    # Spinach's capybara module makes Capybara DSL available in all features.
    #
    # @example
    #   require 'spinach/capybara'
    #   class CapybaraFeature < Spinach::FeatureSteps
    #     Given "I go to the home page" do
    #       visit '/'
    #     end
    #   end
    #
    module Capybara
      # Enhances a FeatureSteps with Capybara goodness.
      #
      # @param [Class] base
      #   The host class.
      #
      # @api public
      def self.included(base)
        base.class_eval do
          include ::Capybara::DSL
        end
        Spinach.hooks.before_scenario do
          ::Capybara.current_session.reset! if ::Capybara.app
        end
      end
    end
  end
end
