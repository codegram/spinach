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
          if defined?(RSpec)
            require 'rspec/matchers'
            require 'capybara/rspec'
            include ::Capybara::RSpecMatchers
          end

          def visit(*args)
            stream = STDOUT
            old_stream = stream.dup
            stream.reopen('/dev/null')
            stream.sync = true
            super
          ensure
            stream.reopen(old_stream)
          end
        end

        Spinach.hooks.after_scenario do
          ::Capybara.current_session.reset! if ::Capybara.app
          ::Capybara.use_default_driver
        end

        Spinach.hooks.on_tag('javascript') do
          ::Capybara.current_driver = ::Capybara.javascript_driver
        end
      end
    end
  end
end
