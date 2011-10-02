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
        puts "\n  #{'Scenario:'.green} #{name.light_green}"
        puts
      end

      # Prints the step name to the standard output. If failed, it puts an
      # F! before
      #
      def step(keyword, name, result)
        case result
          when :success
            puts "    ✔  #{keyword} #{name}".light_green
          when :undefined_step
            puts "    ?  #{keyword} #{name}".light_yellow
          when :failure
            puts "    ✘  #{keyword} #{name}".light_red
          when :error
            puts "    !  #{keyword} #{name}".light_red
          when :skip
            puts "    ~  #{keyword} #{name}".light_cyan
        end
      end

      # Prints a blank line at the end
      #
      def end
        puts ""
      end

      def error_summary(errors)
        puts
        puts "    !  Error summary (#{errors.length})".light_white
        errors.each do |error, step, line, scenario|
          step_file = error.backtrace.detect do |f|
            f =~ /<class:#{scenario.feature.class}>/
          end
          step_file = step_file.split(':')[0..1].join(':') if step_file

          color = if error.kind_of?(Spinach::StepNotDefinedException)
                    :light_yellow
                  else
                    :light_red
                  end

          puts
          puts "       #{scenario.feature_name.underline} :: #{scenario.name.green} :: #{step.colorize(color)} (line #{line})"
          puts "       #{step_file}" if step_file
          error.message.split("\n").each do |line|
            puts "         #{line}".colorize(color)
          end
          if options[:backtrace]
            puts error.backtrace.map {|e| "      #{e}"}
          end
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
