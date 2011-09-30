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
      def step(keyword, name, result)
        case result
          when :success
            puts "    ✔  #{keyword} #{name}".green
          when :undefined_step
            puts "    ?  #{keyword} #{name}".yellow
          when :failure
            puts "    ✘  #{keyword} #{name}".red
          when :error
            puts "    !  #{keyword} #{name}".red
          when :skip
            puts "    ~  #{keyword} #{name}".cyan
        end
      end

      # Prints a blank line at the end
      #
      def end
        puts ""
      end

      def error_summary(errors)
        puts
        puts "    #{"Error summary".underline}"
        puts
        errors.each do |error, step, line, scenario|
          step_file = error.backtrace.detect do |f|
            f =~ /<class:#{scenario.feature.class}>/
          end
          step_file = step_file.split(':')[0..1].join(':') if step_file

          puts
          puts "    #{scenario.feature_name.light_white} :: #{scenario.name.light_blue} :: #{step.light_green} (line #{line})"
          puts "    #{step_file}" if step_file
          puts
          puts "    * #{error.message}".red
          puts error.backtrace.map {|e| "      #{e}"}
          puts
        end
      end

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
