module Spinach
  class Runner
    # A feature runner handles a particular feature run.
    #
    class FeatureRunner

      # The file that describes the feature.
      attr_reader :filename

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

      # @return [Hash]
      #   The parsed data for this feature.
      #
      # @api public
      def data
        @data ||= Spinach::Parser.open_file(filename).parse
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
        Spinach.hooks.run_before_feature data

        scenarios.each do |scenario|
          if !@scenario_line || scenario['line'].to_s == @scenario_line
            success = ScenarioRunner.new(feature_name, scenario).run
            @failed = true unless success
          end
        end

      rescue Spinach::FeatureStepsNotFoundException => e
        Spinach.hooks.run_on_undefined_feature data, e
        @failed = true
      ensure
        Spinach.hooks.run_after_feature data
        return !@failed
      end
    end
  end
end
