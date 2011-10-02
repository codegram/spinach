require 'hooks'

module Spinach
  class Runner
    # A feature runner handles a particular Spinach::Feature run.
    #
    class Feature
      include Hooks

      define_hook :before_run
      define_hook :after_run

      # @param [String] filename
      #   path to the feature file. Scenario line could be passed to run just
      #   that scenario.
      #   @example feature/a_cool_feature.feature:12
      #
      def initialize(filename)
        @filename, @scenario_line = filename.split(':')
      end

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
        run_hook :before_run, data
        feature.run_hook :before, data

        scenarios.each do |scenario|
          if !@scenario_line || scenario['line'].to_s == @scenario_line
            @failure = Scenario.new(feature_name, feature, scenario).run
          end
        end

        feature.run_hook :after, data
        run_hook :after_run, data

        return !@failure
      end
    end
  end
end
