# encoding: utf-8

module Spinach
  class Reporter
    # The Stdout reporter outputs the runner results to the standard output
    #
    class Stdout < Reporter

      def initialize(out = $stdout, error = $stderr, options = {})
        super(options)
        @out = out 
        @error = error
      end

      attr_reader :out, :error

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

      def on_successful_step(step)
        output_step('✔', step, :green)
      end

      def on_failed_step(step, failure)
        output_step('✘', step, :red)
        scenario_error = [current_feature, current_scenario, step, failure]
        failed_steps << scenario_error
      end

      def on_error_step(step, failure)
        output_step('!', step, :red)
        scenario_error = [current_feature, current_scenario, step, failure]
        error_steps << scenario_error
      end

      def on_undefined_step(step, failure)
        output_step('?', step, :yellow)
        scenario_error = [current_feature, current_scenario, step]
        undefined_steps << scenario_error
      end

      def on_skipped_step(step)
        output_step('~', step, :cyan)
      end

      def output_step(symbol, step, color)
        out.puts "    #{symbol.colorize(:"light_#{color}")}  #{step['keyword'].strip.colorize(:"light_#{color}")} #{step['name'].strip.colorize(color)}"
      end

      def after_run(success)
        error_summary
      end

      # Prints the errors for ths run.
      #
      def error_summary
        error.puts ""
        report_error_steps
        report_failed_steps
        report_undefined_steps
      end

      def report_error_steps
        if error_steps.any?
          error.puts "Errors (#{error_steps.length})".light_red
          error_steps.each do |error|
            report_error error
          end
          error.puts ""
        end
      end

      def report_failed_steps
        if failed_steps.any?
          error.puts "Failures (#{failed_steps.length})".light_red
          failed_steps.each do |error|
            report_error error
          end
          error.puts ""
        end
      end

      def report_undefined_steps
        if undefined_steps.any?
          error.puts "Undefined steps (#{undefined_steps.length})".yellow
          undefined_steps.each do |error|
            report_error error
          end
          error.puts ""
        end
      end

      def report_error(error, format=:summarized)
        case format
          when :summarized
            error.puts summarized_error(error)
          when :full
            error.puts full_error(error)
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
