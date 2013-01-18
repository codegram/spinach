# encoding: utf-8
require_relative 'stdout/error_reporting'

module Spinach
  class Reporter
    # The Progress reporter outputs the runner results to the standard output
    #
    class Progress < Reporter

      include Stdout::ErrorReporting

      # The output buffers to store the reports.
      attr_reader :out, :error

      # The last scenario error
      attr_accessor :scenario_error

      # The last scenario
      attr_accessor :scenario

      # Initialitzes the runner
      #
      # @param [Hash] options
      #  Sets a custom output buffer by setting options[:output]
      #  Sets a custom error buffer by setting options[:error]
      #
      def initialize(*args)
        super(*args)
        @out = options[:output] || $stdout
        @error = options[:error] || $stderr
      end

      # Adds a passed step to the output buffer.
      #
      # @param [Step] step
      #   The step.
      #
      # @param [Array] step_location
      #   The step source location
      #
      def on_successful_step(step, step_location, step_definitions = nil)
        output_step('.', :green)
        self.scenario = [current_feature, current_scenario, step]
        successful_steps << scenario
      end

      # Adds a failing step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      # @param [Exception] failure
      #   The exception that caused the failure
      #
      def on_failed_step(step, failure, step_location, step_definitions = nil)
        output_step('F', :red)
        self.scenario_error = [current_feature, current_scenario, step, failure]
        failed_steps << scenario_error
      end

      # Adds a step that has raised an error to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      # @param [Exception] failure
      #   The exception that caused the failure
      #
      def on_error_step(step, failure, step_location, step_definitions = nil)
        output_step('E', :red)
        self.scenario_error = [current_feature, current_scenario, step, failure]
        error_steps << scenario_error
      end

      # Adds an undefined step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      def on_undefined_step(step, failure, step_definitions = nil)
        output_step('U', :yellow)
        self.scenario_error = [current_feature, current_scenario, step, failure]
        undefined_steps << scenario_error
      end

      # Adds an undefined step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      def on_pending_step(step, failure)
        output_step('P', :yellow)
        self.scenario_error = [current_feature, current_scenario, step, failure]
        pending_steps << scenario_error
      end

      # Adds a step that has been skipped to the output buffer.
      #
      # @param [Hash] step
      #   The step that Gherkin extracts
      #
      def on_skipped_step(step, step_definitions = nil)
        output_step('~', :cyan)
      end

      # Adds to the output buffer a step result
      #
      # @param [String] text
      #   A symbol to prepend before the step keyword (might be useful to
      #   indicate if everything went ok or not).
      #
      # @param [Symbol] color
      #   The color code to use with Colorize to colorize the output.
      #
      def output_step(text, color = :grey)
        out.print(text.to_s.colorize(color))
      end

      # It prints the error summary if the run has failed
      # It always print feature success summary
      #
      # @param [True,False] success
      #   whether the run has succeed or not
      #
      def after_run(success)
        error_summary unless success
        out.puts ""
        run_summary
      end

      # Prints the feature success summary for this run.
      #
      def run_summary
        successful_summary = format_summary(:green,  successful_steps, 'Successful')
        undefined_summary  = format_summary(:yellow, undefined_steps,  'Undefined')
        pending_summary    = format_summary(:yellow, pending_steps,    'Pending')
        failed_summary     = format_summary(:red,    failed_steps,     'Failed')
        error_summary      = format_summary(:red,    error_steps,      'Error')

        out.puts "Steps Summary: #{successful_summary}, #{undefined_summary}, #{pending_summary}, #{failed_summary}, #{error_summary}\n\n"
      end

      private
      def format_summary(color, steps, message)
        buffer = []
        buffer << "(".colorize(color)
        buffer << steps.length.to_s.colorize(:"light_#{color}")
        buffer << ") ".colorize(color)
        buffer << message.colorize(color)
        buffer.join
      end
    end
  end
end

