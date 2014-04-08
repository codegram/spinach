require 'capybara'
require 'capybara/dsl'
require 'rbconfig'
require 'spinach/config'
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
      include ::Capybara::DSL

      if defined?(RSpec)
        require 'rspec/matchers'
        require 'capybara/rspec'
        include ::Capybara::RSpecMatchers
      end

      alias_method :capybara_visit, :visit

      def visit(*args)
        stream = STDOUT
        old_stream = stream.dup
        stream.reopen(null_device)
        stream.sync = true
        capybara_visit *args
      ensure
        stream.reopen(old_stream)
      end

      def null_device
        return @null_device if defined?(@null_device)

        if RbConfig::CONFIG["host_os"] =~ /mingw|mswin/
          @null_device = "NUL"
        else
          @null_device = "/dev/null"
        end

        @null_device
      end
    end
  end
end

Spinach.hooks.after_scenario do
  ::Capybara.reset_sessions! if ::Capybara.app
  ::Capybara.use_default_driver
end

Spinach.hooks.on_tag('javascript') do
  ::Capybara.current_driver = ::Capybara.javascript_driver
end

open_page = Proc.new do |*args|
  if Spinach.config.save_and_open_page_on_failure
    step_definitions = args.last
    step_definitions.send(:save_and_open_page)
  end
end

Spinach.hooks.on_error_step(&open_page)
Spinach.hooks.on_failed_step(&open_page)

Spinach::FeatureSteps.send :include, Spinach::FeatureSteps::Capybara
