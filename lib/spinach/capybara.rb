require 'capybara'
require 'capybara/dsl'
require_relative 'feature'

module Spinach
  class Feature

    # Spinach's capybara module integrates capybara into all features
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
      def self.included(base)
        base.class_eval do
          include ::Capybara::DSL
        end
      end
    end
  end
end

Spinach::Feature.send(:include, Spinach::Feature::Capybara)
