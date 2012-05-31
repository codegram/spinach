# encoding: utf-8
require_relative 'stdout/error_reporting'

module Spinach
  class Reporter
    # The Stdout reporter outputs the runner results to the standard output
    #
    class Stdout < Reporter

      include ErrorReporting

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
        @max_step_name_length = 0
      end

      # Prints the feature name to the standard output
      #
      # @param [Hash] data
      #   The feature in a JSON Gherkin format
      #
      def before_feature_run(feature)
        name = feature.name
        out.puts "\n#{'Feature:'.magenta} #{name.light_magenta}"
      end

      # Prints the scenario name to the standard ouput
      #
      # @param [Hash] data
      #   The feature in a JSON Gherkin format
      #
      def before_scenario_run(scenario, step_definitions = nil)
        @max_step_name_length = scenario.steps.map(&:name).map(&:length).max if scenario.steps.any?
        name = scenario.name
        out.puts "\n  #{'Scenario:'.green} #{name.light_green}"
      end

      # Adds an error report and re
      #
      # @param [Hash] data
      #   The feature in a JSON Gherkin format
      #
      def after_scenario_run(scenario, step_definitions = nil)
        if scenario_error
          report_error(scenario_error, :full)
          self.scenario_error = nil
        end
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
        output_step('✔', step, :green, step_location)
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
        output_step('✘', step, :red, step_location)
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
        output_step('!', step, :red, step_location)
        self.scenario_error = [current_feature, current_scenario, step, failure]
        error_steps << scenario_error
      end

      # Adds an undefined step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      def on_undefined_step(step, failure, step_definitions = nil)
        output_step('?', step, :yellow)
        self.scenario_error = [current_feature, current_scenario, step, failure]
        undefined_steps << scenario_error
      end

      # Adds an undefined step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      def on_pending_step(step, failure)
        output_step('P', step, :yellow)
        self.scenario_error = [current_feature, current_scenario, step, failure]
        pending_steps << scenario_error
      end

      # Adds a feature not found message to the output buffer.
      #
      # @param [Hash] feature
      #   the feature in a json gherkin format
      #
      # @param [Spinach::FeatureNotFoundException] exception
      #   the related exception
      #
      def on_feature_not_found(feature)
        generator = Generators::FeatureGenerator.new(feature)
        lines = "Could not find steps for `#{feature.name}` feature\n\n"
        lines << "\nPlease create the file #{generator.filename} at #{generator.path}, with:\n\n"

        lines << generator.generate

        lines.split("\n").each do |line|
          out.puts "    #{line}".yellow
        end
        out.puts "\n\n"

        undefined_features << feature
      end

      # Adds a step that has been skipped to the output buffer.
      #
      # @param [Hash] step
      #   The step that Gherkin extracts
      #
      def on_skipped_step(step, step_definitions = nil)
        output_step('~', step, :cyan)
      end

      # Adds to the output buffer a step result
      #
      # @param [String] symbol
      #   A symbol to prepend before the step keyword (might be useful to
      #   indicate if everything went ok or not).
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      # @param [Symbol] color
      #   The color code to use with Colorize to colorize the output.
      #
      # @param [Array] step_location
      #   step source location and file line
      #
      def output_step(symbol, step, color, step_location = nil)
        step_location = step_location.first.gsub("#{File.expand_path('.')}/", '# ')+":#{step_location.last.to_s}" if step_location
        max_length = @max_step_name_length + 60 # Colorize and output format correction

        # REMEMBER TO CORRECT PREVIOUS MAX LENGTH IF OUTPUT FORMAT IS MODIFIED
        buffer = []
        buffer << indent(4)
        buffer << symbol.colorize(:"light_#{color}")
        buffer << indent(2)
        buffer << step.keyword.colorize(:"light_#{color}")
        buffer << indent(1)
        buffer << step.name.colorize(color)
        joined = buffer.join.ljust(max_length)

        out.puts(joined + step_location.to_s.colorize(:grey))
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

      # Constructs the full step definition
      #
      # @param [Hash] step
      #   The step.
      #
      def full_step(step)
        "#{step.keyword} #{step.name}"
      end

      private

      def indent(n = 1)
        " " * n
      end

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
