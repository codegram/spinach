# encoding: utf-8
require_relative 'reporting'
require 'pp'

module Spinach
  class Reporter
    # The FailureFile reporter outputs failing scenarios to a temporary file, one per line.
    #
    class FailureFile < Reporter

      # Initializes the output filename and the temporary directory.
      #
      def initialize(*args)
        super(*args)

        # Generate a unique filename for this test run, or use the supplied option
        @filename = options[:failure_filename] || ENV['SPINACH_FAILURE_FILE'] || "tmp/spinach-failures_#{Time.now.strftime('%F_%H-%M-%S-%L')}.txt"

        # Create the temporary directory where we will output our file, if necessary
        Dir.mkdir('tmp', 0755) unless Dir.exist?('tmp')

        # Collect an array of failing scenarios
        @failing_scenarios = []
      end

      attr_reader :failing_scenarios, :filename

      # Writes all failing scenarios to a file, unless our run was successful.
      #
      # @param [Boolean] success
      #   Indicates whether the entire test run was successful
      #
      def after_run(success)
        # Save our failed scenarios to a file
        File.open(@filename, 'w') { |f| f.write @failing_scenarios.join("\n") } unless success
      end

      # Adds a failing step to the output buffer.
      #
      def on_failed_step(*args)
        add_scenario(current_feature.filename, current_scenario.lines[0])
      end

      # Adds a step that has raised an error to the output buffer.
      #
      def on_error_step(*args)
        add_scenario(current_feature.filename, current_scenario.lines[0])
      end

      private

      # Adds a filename and line number to the output buffer, suitable for rerunning.
      #
      def add_scenario(filename, line)
        @failing_scenarios << "#{filename}:#{line}"
      end
    end
  end
end