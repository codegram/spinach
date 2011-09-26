require 'capybara'
require 'capybara/dsl'

module Spinach
  class Feature
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
