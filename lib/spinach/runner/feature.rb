module Spinach
  class Runner
    # A feature runner handles a particular Spinach::Feature run.
    #
    class Feature
      # @param [String] filename
      #   path to the feature file. Scenario line could be passed to run just
      #   that scenario.
      #   @example feature/a_cool_feature.feature:12
      #
      # @param [Spinach::Reporter] reporter
      #   the reporter that will log this run
      #
      def initialize(filename, reporter)
        @filename, @scenario_line = filename.split(':')
        @reporter = reporter
      end

      # The [Reporter] used in this feature.
      #
      attr_reader :reporter

      # The file taht describes the feature.
      #
      attr_reader :filename

      # @return [Spinach::Feature]
      #   the feature towards which this scenario will be run
      #
      def feature
        @feature ||= Spinach.find_feature(feature_name).new
      end

      # @return [Hash]
      #   the parsed data for this feature
      #
      def data
        @data ||= Spinach::Parser.new(filename).parse
      end

      # @return [String]
      #   this feature's name
      #
      def feature_name
        @feature_name ||= data['name']
      end

      # @return [Hash]
      #   the parsed scenarios for this runner's feature
      #
      def scenarios
        @scenarios ||= (data['elements'] || [])
      end

      # Runs this feature
      #
      def run
        reporter.feature(feature_name)
        failures = []

        feature.run_hook :before, feature_name

        scenarios.each do |scenario|
          if !@scenario_line || scenario['line'].to_s == @scenario_line
            failure = Scenario.new(feature_name, feature, scenario, reporter).run
            failures << failure if failure
          end
        end

        feature.run_hook :after, feature_name

        if failures.any?
          reporter.error_summary(failures)
          false
        else
          true
        end
      end
    end
  end
end
