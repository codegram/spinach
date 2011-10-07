# encoding: utf-8

module Spinach
  class Reporter
    # The Stdout reporter outputs the runner results to the standard output
    #
    class Stdout < Reporter

      def initialize(*args)
        super(*args)
        @out = options[:output] || $stdout
        @err = options[:error] || $stderr
      end

      attr_reader :out, :err

      attr_accessor :scenario_error

      # Prints the feature name to the standard output
      #
      def before_feature_run(data)
        name = data['name']
        out.puts "\n#{'Feature:'.magenta} #{name.light_magenta}"
      end

      # Prints the scenario name to the standard ouput
      #
      def before_scenario_run(data)
        name = data['name']
        out.puts "\n  #{'Scenario:'.green} #{name.light_green}"
        out.puts
      end

      def after_scenario_run(data)
        if scenario_error
          report_error scenario_error, :full
        end
        self.scenario_error = nil
      end

      # Adds a passed step to the output buffer.
      #
      # @param [Hash] step
      #   The step in a JSON Gherkin format
      #
      # @example
      #  @report.on_successful_step({'keyword' => 'Given', 'name' => 'I am too cool'})
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
        err.puts "\nError summary:\n"
        report_error_steps
        report_failed_steps
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
        err.puts "#{banner} (#{steps.length})".colorize(color)
        steps.each do |error|
          report_error error
        end
        err.puts ""
      end

      # Prints an error in a nice format
      #
      # @param [Array] error
      #  An array containing the feature, scenario, step an exception
      #
      # @param [Symbol] format
      #   The format to output the error. Currently supproted formats are
      #   :summarized (default) and :full
      #
      def report_error(error, format=:summarized)
        case format
          when :summarized
            err.puts summarized_error(error)
          when :full
            err.puts full_error(error)
          else
            raise "Format not defined"
        end
      end

      def summarized_error(error)
        feature, scenario, step, exception = error
        summary = "  #{feature['name']} :: #{scenario['name']} :: #{full_step step}"
        if exception.kind_of?(Spinach::StepNotDefinedException)
          summary.yellow
        else
          summary.red
        end
      end

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

      def full_step(step)
        "#{step['keyword'].strip} #{step['name'].strip}"
      end

      # Prints a nice backtrace when an exception is raised.
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
