# encoding: utf-8

module Spinach
  class Reporter
    # The Stdout reporter outputs the runner results to the standard output
    #
    class Stdout < Reporter

      # Prints the feature name to the standard output
      #
      def feature(name)
        puts "\nFeature: #{name}".white.underline
      end

      # Prints the scenario name to the standard ouput
      #
      def scenario(name)
        puts "\n  Scenario: #{name}".white
      end

      # Prints the step name to the standard output. If failed, it puts an
      # F! before
      #
      def step(keyword, name, result, exception=nil)
        case result
          when :success
            puts "    ✔  #{keyword} #{name}".green
          when :undefined_step
            puts "    ?  #{keyword} #{name}".yellow
            report_exception exception
          when :failure
            puts "    ✘  #{keyword} #{name}".red
            report_exception exception
          when :error
            puts "    !  #{keyword} #{name}".red
            report_exception exception
          when :skip
            puts "    ~  #{keyword} #{name}".cyan
        end
      end

      # Prints a blank line at the end
      #
      def end
        puts ""
      end

      def report_exception(exception)
        output = exception.message.split("\n").map{ |line|
          "        #{line}"
        }.join("\n")
        puts "#{output}\n\n"
      end

    end
  end
end
