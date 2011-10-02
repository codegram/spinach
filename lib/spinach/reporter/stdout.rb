# encoding: utf-8

module Spinach
  class Reporter
    # The Stdout reporter outputs the runner results to the standard output
    #
    class Stdout < Reporter
      # Prints the feature name to the standard output
      #
      def feature(data)
        name = data['name']
        puts "\n#{'Feature:'.magenta} #{name.light_magenta}"
      end

      # Prints the scenario name to the standard ouput
      #
      def scenario(data)
        name = data['name']
        puts "\n  #{'Scenario:'.green} #{name.light_green}"
        puts
      end

      def after_scenario
        if @scenario_error
          puts ""
          report_error @scenario_error, :backtrace
        end
        @scenario_error = nil
      end

      # Prints the step name to the standard output. If failed, it puts an
      # F! before
      #
      def step(step, result, failure=nil)
        color, symbol = case result
          when :success
            [:green, '✔']
          when :undefined_step
            @scenario_error = [current_feature, current_scenario, step]
            undefined_steps << @scenario_error
            [:yellow, '?']
          when :failure
            @scenario_error = [current_feature, current_scenario, step, failure]
            failed_steps << @scenario_error
            [:red, '✘']
          when :error
            @scenario_error = [current_feature, current_scenario, step, failure]
            error_steps << @scenario_error
            [:red, '!']
          when :skip
            [:cyan, '~']
        end
        puts "    #{symbol.colorize(:"light_#{color}")}  #{step['keyword'].strip.colorize(:"light_#{color}")} #{step['name'].strip.colorize(color)}"
      end

      def end(success)
        error_summary
      end

      # Prints the errors for ths run.
      #
      def error_summary
        puts ""
        report_error_steps
        report_failed_steps
        report_undefined_steps
      end

      def report_error_steps
        if error_steps.any?
          puts "Errors (#{error_steps.length})".light_red
          error_steps.each do |error|
            report_error error
          end
          puts ""
        end
      end

      def report_failed_steps
        if failed_steps.any?
          puts "Failures (#{failed_steps.length})".light_red
          failed_steps.each do |error|
            report_error error
          end
          puts ""
        end
      end

      def report_undefined_steps
        if undefined_steps.any?
          puts "Undefined steps (#{undefined_steps.length})".yellow
          undefined_steps.each do |error|
            report_error error
          end
          puts ""
        end
      end

      def report_error(error, format=:summarized)
        if format == :summarized
          puts summarized_error(error)
        else
          puts full_error(error)
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
        output = report_exception(exception)

        if exception.kind_of?(Spinach::StepNotDefinedException)
          output.yellow
        else
          output.red
        end

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
      end
    end
  end
end
