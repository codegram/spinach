# encoding: utf-8

module Spinach
  class Reporter
    # The Stdout reporter outputs the runner results to the standard output
    #
    class Stdout < Reporter
      # Prints the feature name to the standard output
      #
      def feature(name)
        puts "\n#{'Feature:'.magenta} #{name.light_magenta}"
      end

      # Prints the scenario name to the standard ouput
      #
      def scenario(name)
        puts "\n  #{'Scenario:'.green} #{name.light_green}"
        puts
      end

      # Prints the step name to the standard output. If failed, it puts an
      # F! before
      #
      def step(step, result, failure=nil)
        color, symbol = case result
          when :success
            [:green, '✔']
          when :undefined_step
            undefined_steps << [step]
            [:yellow, '?']
          when :failure
            failed_steps << [step, failure]
            [:red, '✘']
          when :error
            error_steps << [step, failure]
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
        puts "Errors (#{error_steps.length})".light_red
        puts ""
      end

      def report_failed_steps
        puts "Failures (#{failed_steps.length})".red
        puts ""
      end

      def report_undefined_steps
        puts "Undefined steps (#{undefined_steps.length})".yellow
        puts ""
      end

      def report_error(error)
        puts error.inspect
      end

      # Prints a nice backtrace when an exception is raised.
      #
      def report_exception(exception)
        @errors << exception
        output = exception.message.split("\n").map{ |line|
          "        #{line}"
        }.join("\n")
        puts "#{output}\n\n"
      end
    end
  end
end
