require 'capybara'
require 'capybara/dsl'
require_relative 'feature'

module Spinach
  class Feature
    # Spinach's capybara module makes Capybara DSL available in all features.
    #
    # @example
    #   require 'spinach/capybara'
    #   class CapybaraFeature < Spinach::Feature
    #     Given "I go to the home page" do
    #       visit '/'
    #     end
    #   end
    #
    module Capybara
      # Enhances a Feature with Capybara goodness.
      #
      # @param [Class] base
      #   The host class.
      #
      # @api public
      def self.included(base)
        base.class_eval do
          include ::Capybara::DSL

          after_scenario do
            ::Capybara.current_session.reset! if ::Capybara.app
          end
        end
      end
    end
  end
end
