require 'colorize'

module Spinach
  # Spinach reporter collects information from Runner hooks and outputs the
  # results
  #
  class Reporter

    # Receives this hook when a feature is invoked
    # @param [String] name
    #   the feature name
    #
    def feature(name)
      raise "Abstract method!"
    end

    # Receives this hook when a scenario is invoked
    # @param [String] name
    #   the scenario name
    #
    def scenario(name)
      raise "Abstract method!"
    end

    # Receives this hook when a step is invoked
    # @param [String] name
    #   the scenario name
    # @param [Symbol] result
    #   the step name and its finishing state. May be :success or :failure
    #
    def step(name, result)
      raise "Abstract method!"
    end

    # The Stdout reporter outputs the runner results to the standard output
    #
    class Stdout < Reporter

      # Prints the feature name to the standard output
      #
      def feature(name)
        puts "\nFeature: #{name}".green
      end

      # Prints the scenario name to the standard ouput
      #
      def scenario(name)
        puts "\tScenario: #{name}".green
      end

      # Prints the step name to the standard output. If failed, it puts an
      # F! before
      #
      def step(name, result)
        words = name.split(" ")
        connector = words.shift
        phrase = words.join(" ")
        if result == :success
          puts "\t\t#{connector} #{phrase}".green
        else
          puts "\t\tF! #{connector} #{phrase}".red
        end
      end
    end
  end
end
