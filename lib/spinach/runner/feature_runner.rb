module Spinach
  class Runner
    # A feature runner handles a particular feature run.
    #
    class FeatureRunner
      attr_reader :feature

      # @param [Gherkin::AST::Feature] feature
      #   The feature to run.
      #
      # @param [#to_i] line
      #   If a scenario line is passed, then only the scenario defined on that
      #   line will be run.
      #
      # @api public
      def initialize(feature, line=nil)
        @feature = feature
        @line    = line.to_i if line
      end

      # @return [String]
      #   This feature name.
      #
      # @api public
      def feature_name
        @feature.name
      end

      # @return [Array<Gherkin::AST::Scenario>]
      #   The parsed scenarios for this runner's feature.
      #
      # @api public
      def scenarios
        @feature.scenarios
      end

      # Runs this feature.
      #
      # @return [true, false]
      #   Whether the run was successful or not.
      #
      # @api public
      def run
        Spinach.hooks.run_before_feature @feature
        if Spinach.find_feature_steps(feature_name)
          run_scenarios!
        else
          undefined_steps!
        end
        Spinach.hooks.run_after_feature @feature
        !@failed
      end

      private

      def run_scenarios!
        scenarios.each do |scenario|
          if !@scenario_line || (scenario.line == @scenario_line)
            success = ScenarioRunner.new(feature_name, scenario).run
            @failed = true unless success
          end
        end
      end

      def undefined_steps!
        Spinach.hooks.run_on_undefined_feature @feature
        @failed = true
      end
    end
  end
end
