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
      def step(name, result)
        words = name.split(" ")
        connector = words.shift
        phrase = words.join(" ")
        if result == :success
          puts "    ✔  #{connector} #{phrase}".green
        elsif result == :failure
          puts "    ✘  #{connector} #{phrase}".red
        elsif result == :undefined_step
          puts "    ?  #{connector} #{phrase}".yellow
        elsif result == :skip
          puts "    ~  #{connector} #{phrase}".cyan
        end
      end

      # Prints a blank line at the end
      #
      def end
        puts ""
      end

    end
  end
end
