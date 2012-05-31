module Spinach
  class Reporter
    class Stdout < Reporter
      # This module handles Stdout's reporter error reporting capabilities.
      module ErrorReporting

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
          report_errors('Undefined steps', undefined_steps, :yellow) if undefined_steps.any?
        end

        def report_pending_steps
          report_errors('Pending steps', pending_steps, :yellow) if pending_steps.any?
        end

        def report_undefined_features
          if undefined_features.any?
            error.puts "  Undefined features (#{undefined_features.length})".light_yellow
            undefined_features.each do |feature|
              error.puts "    #{feature.name}".yellow
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
            summary.yellow
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
            output << "        You can define it with: \n\n".yellow
            suggestion = Generators::StepGenerator.new(step).generate
            suggestion.split("\n").each do |line|
              output << "          #{line}\n".yellow
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
            output.yellow
          elsif exception.kind_of?(Spinach::StepPendingException)
            output.yellow
          else
            output.red
          end
        end

      end
    end
  end
end
