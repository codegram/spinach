require 'hooks'

module Spinach
  class Runner
    # A feature runner handles a particular feature run.
    #
    class Feature
      include Hooks

      # The {Reporter} used in this feature.
      attr_reader :reporter

      # The file that describes the feature.
      attr_reader :filename

      define_hook :before_run
      define_hook :after_run

      # @param [String] filename
      #   path to the feature file. Scenario line could be passed to run just
      #   that scenario.
      #   @example feature/a_cool_feature.feature:12
      #
      # @api public
      def initialize(filename)
        @filename, @scenario_line = filename.split(':')
      end

      # The file taht describes the feature.
      #
      attr_reader :filename

      # @return [Feature]
      #   The feature object used to run this scenario.
      #
      # @api public
      def feature
        @feature ||= Spinach.find_feature(feature_name).new
      end

      # @return [Hash]
      #   The parsed data for this feature.
      #
      # @api public
      def data
        @data ||= Spinach::Parser.new(filename).parse
      end

      # @return [String]
      #   This feature name.
      #
      # @api public
      def feature_name
        @feature_name ||= data['name']
      end

      # @return [Hash]
      #   The parsed scenarios for this runner's feature.
      #
      # @api public
      def scenarios
        @scenarios ||= (data['elements'] || [])
      end

      # Runs this feature.
      #
      # @return [true, false]
      #   Whether the run was successful or not.
      #
      # @api public
      def run
        run_hook :before_run, feature_name
        feature.run_hook :before, feature_name

        scenarios.each do |scenario|
          if !@scenario_line || scenario['line'].to_s == @scenario_line
            @failure = Scenario.new(feature_name, feature, scenario).run
          end
        end

        feature.run_hook :after, feature_name
        run_hook :after_run, feature_name

        return !@failure
      end
    end
  end
end
