# encoding: utf-8

module Spinach
  class Reporter
    # The Stdout reporter outputs the runner results to the standard output
    #
    class Stdout < Reporter

      # The output buffers to store the reports.
      attr_reader :out, :error

      # The last scenario error
      attr_accessor :scenario_error

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

      # Prints the feature name to the standard output
      #
      # @param [Hash] data
      #   The feature in a JSON Gherkin format
      #
      def before_feature_run(data)
        name = data['name']
        out.puts "\n#{'Feature:'.magenta} #{name.light_magenta}"
      end

      # Prints the scenario name to the standard ouput
      #
      # @param [Hash] data
      #   The feature in a JSON Gherkin format
      #
      def before_scenario_run(data)
        name = data['name']
        out.puts "\n  #{'Scenario:'.green} #{name.light_green}"
        out.puts
      end

      # Adds an error report and re
      #
      # @param [Hash] data
      #   The feature in a JSON Gherkin format
      #
      def after_scenario_run(data)
        if scenario_error
          report_error(scenario_error, :full)
          self.scenario_error = nil
        end
      end

      # Adds a passed step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      def on_successful_step(step)
        output_step('✔', step, :green)
      end

      # Adds a failing step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      # @param [Exception] failure
      #   The exception that caused the failure
      #
      def on_failed_step(step, failure)
        output_step('✘', step, :red)
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
      def on_error_step(step, failure)
        output_step('!', step, :red)
        self.scenario_error = [current_feature, current_scenario, step, failure]
        error_steps << scenario_error
      end

      # Adds an undefined step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      def on_undefined_step(step)
        output_step('?', step, :yellow)
        self.scenario_error = [current_feature, current_scenario, step]
        undefined_steps << scenario_error
      end

      # Adds a feature not found message to the output buffer.
      #
      # @param [Hash] feature
      #   the feature in a json gherkin format
      #
      # @param [Spinach::FeatureNotFoundException] exception
      #   the related exception
      #
      def on_feature_not_found(feature, exception)
        lines = "#{exception.message}\n"

        lines << "\nPlease create the file #{Spinach::Support.underscore(exception.missing_class)}.rb at #{Spinach.config[:step_definitions_path]}, with:\n\n"

        lines << "Feature '#{feature['name']}' do\n"

        # TODO: Write the actual steps. We can do this since we have the entire
        # feature just here. We should iterate over all the scenarios and return
        # the different steps
        #
        lines << "  # Write your steps here"
        lines << "end\n\n"

        lines.split("\n").each do |line|
          out.puts "    #{line}".yellow
        end

        undefined_features << feature
      end

      # Adds a step that has been skipped to the output buffer.
      #
      # @param [Hash] step
      #   The step that Gherkin extracts
      #
      def on_skipped_step(step)
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
      def output_step(symbol, step, color)
        out.puts "    #{symbol.colorize(:"light_#{color}")}  #{step['keyword'].strip.colorize(:"light_#{color}")} #{step['name'].strip.colorize(color)}"
      end

      # It prints the error summary if the run has failed
      #
      # @param [True,False] success
      #   whether the run has succeed or not
      #
      def after_run(success)
        error_summary unless success
      end

      # Prints the errors for ths run.
      #
      def error_summary
        error.puts "\nError summary:\n"
        report_error_steps
        report_failed_steps
        report_undefined_features
        report_undefined_steps
      end

      # Prints the steps that raised an error.
      #
      def report_error_steps
        report_errors('Errors', error_steps, :light_red) if error_steps.any?
      end

      # Prints failing steps.
      #
      def report_failed_steps
        report_errors('Failures', failed_steps, :light_red) if failed_steps.any?
      end

      # Prints undefined steps.
      #
      def report_undefined_steps
        report_errors('Undefined steps', undefined_steps, :yellow) if undefined_steps.any?
      end

      def report_undefined_features
        if undefined_features.any?
          error.puts "  Undefined features (#{undefined_features.length})".light_yellow
          undefined_features.each do |feature|
            error.puts "    #{feature['name']}".yellow
          end
        end
      end

      # Prints the error for a given set of steps
      #
      # @param [String] banner
      #   the text to prepend as the title
      #
      # @param [Array] steps
      #   the steps to output
      #
      # @param [Symbol] color
      #   The color code to use with Colorize to colorize the output.
      #
      def report_errors(banner, steps, color)
        error.puts "  #{banner} (#{steps.length})".colorize(color)
        steps.each do |error|
          report_error error
        end
        error.puts ""
      end

      # Prints an error in a nice format
      #
      # @param [Array] error
      #  An array containing the feature, scenario, step and exception
      #
      # @param [Symbol] format
      #   The format to output the error. Currently supproted formats are
      #   :summarized (default) and :full
      #
      # @returns [String]
      #  The error report
      #
      def report_error(error, format=:summarized)
        case format
          when :summarized
            self.error.puts summarized_error(error)
          when :full
            self.error.puts full_error(error)
          else
            raise "Format not defined"
        end
      end

      # Returns summarized error report
      #
      # @param [Array] error
      #  An array containing the feature, scenario, step and exception
      #
      # @returns [String]
      #  The summarized error report
      #
      def summarized_error(error)
        feature, scenario, step, exception = error
        summary = "    #{feature['name']} :: #{scenario['name']} :: #{full_step step}"
        if exception.kind_of?(Spinach::StepNotDefinedException)
          summary.yellow
        else
          summary.red
        end
      end

      # Returns a complete error report
      #
      # @param [Array] error
      #  An array containing the feature, scenario, step and exception
      #
      # @returns [String]
      #  The coplete error report
      #
      def full_error(error)
        feature, scenario, step, exception = error
        output = String.new
        output += report_exception(exception)
        output +="\n"

        if options[:backtrace]
          output += "\n"
          exception.backtrace.map do |line|
            output << "        #{line}\n"
          end
        else
          output << "        #{exception.backtrace[0]}"
        end
        output
      end

      # Constructs the full step definition
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      def full_step(step)
        "#{step['keyword'].strip} #{step['name'].strip}"
      end

      # Prints a information when an exception is raised.
      #
      # @param [Exception] exception
      #   The exception to report
      #
      # @returns [String]
      #  The exception report
      #
      def report_exception(exception)
        output = exception.message.split("\n").map{ |line|
          "        #{line}"
        }.join("\n")

        if exception.kind_of?(Spinach::StepNotDefinedException)
          output.yellow
        else
          output.red
        end
      end
    end
  end
end
