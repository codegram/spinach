module Spinach
  class Reporter
    # This module handles Stdout's reporter error reporting capabilities.
    module Reporting

      # The output buffers to store the reports.
      attr_reader :out, :error

      # The last scenario error
      attr_accessor :scenario_error

      # The last scenario
      attr_accessor :scenario

      # Prints the errors for this run.
      #
      def error_summary
        error.puts "\nError summary:\n"
        report_error_steps
        report_failed_steps
        report_undefined_features
        report_undefined_steps
        report_pending_steps
      end

      def report_error_steps
        report_errors('Errors', error_steps, :light_red) if error_steps.any?
      end

      def report_failed_steps
        report_errors('Failures', failed_steps, :light_red) if failed_steps.any?
      end

      def report_undefined_steps
        if undefined_steps.any?
          error.puts "\nUndefined steps summary:\n"
          report_errors('Undefined steps', undefined_steps, :red)
        end
      end

      def report_pending_steps
        if pending_steps.any?
          error.puts "\nPending steps summary:\n"
          report_errors('Pending steps', pending_steps, :yellow)
        end
      end

      def report_undefined_features
        if undefined_features.any?
          error.puts "  Undefined features (#{undefined_features.length})".red
          undefined_features.each do |feature|
            error.puts "    #{feature.name}".red
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
      # @return [String]
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
      # @return [String]
      #  The summarized error report
      #
      def summarized_error(error)
        feature, scenario, step, exception = error
        summary = "    #{feature.name} :: #{scenario.name} :: #{full_step step}"
        if exception.kind_of?(Spinach::StepNotDefinedException)
          summary.red
        elsif exception.kind_of?(Spinach::StepPendingException)
          summary += "\n      Reason: '#{exception.reason}'\n"
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
      # @return [String]
      #  The coplete error report
      #
      def full_error(error)
        feature, scenario, step, exception = error
        output = "\n"
        output += report_exception(exception)
        output +="\n"

        if exception.kind_of?(Spinach::StepNotDefinedException)
          output << "\n"
          output << "        You can define it with: \n\n".red
          suggestion = Generators::StepGenerator.new(step).generate
          suggestion.split("\n").each do |line|
            output << "          #{line}\n".red
          end
          output << "\n"
        elsif exception.kind_of?(Spinach::StepPendingException)
          output << "        Reason: '#{exception.reason}'".yellow
          output << "\n"
        else
          if options[:backtrace]
            output += "\n"
            exception.backtrace.map do |line|
              output << "        #{line}\n"
            end
          else
            output << "        #{exception.backtrace[0]}"
          end
        end
        output
      end

      # Prints a information when an exception is raised.
      #
      # @param [Exception] exception
      #   The exception to report
      #
      # @return [String]
      #  The exception report
      #
      def report_exception(exception)
        output = exception.message.split("\n").map{ |line|
          "        #{line}"
        }.join("\n")

        if exception.kind_of?(Spinach::StepNotDefinedException)
          output.red
        elsif exception.kind_of?(Spinach::StepPendingException)
          output.yellow
        else
          output.red
        end
      end

      # Constructs the full step definition
      #
      # @param [Hash] step
      #   The step.
      #
      def full_step(step)
        "#{step.keyword} #{step.name}"
      end

      def format_summary(color, steps, message)
        buffer = []
        buffer << "(".colorize(color)
        buffer << steps.length.to_s.colorize(:"light_#{color}")
        buffer << ") ".colorize(color)
        buffer << message.colorize(color)
        buffer.join
      end

      def before_run(*)
        @start_time = Time.now
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
        undefined_summary  = format_summary(:red,    undefined_steps,  'Undefined')
        pending_summary    = format_summary(:yellow, pending_steps,    'Pending')
        failed_summary     = format_summary(:red,    failed_steps,     'Failed')
        error_summary      = format_summary(:red,    error_steps,      'Error')

        out.puts "Steps Summary: #{successful_summary}, #{pending_summary}, #{undefined_summary}, #{failed_summary}, #{error_summary}\n\n"
        out.puts "Finished in #{Time.now - @start_time} seconds" if @start_time
      end
    end
  end
end
