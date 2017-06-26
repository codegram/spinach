require_relative '../tags_matcher'

module Spinach
  class Runner
    # A feature runner handles a particular feature run.
    #
    class FeatureRunner
      attr_reader :feature

      # @param [GherkinRuby::AST::Feature] feature
      #   The feature to run.
      #
      # @api public
      def initialize(feature)
        @feature = feature
      end

      # @return [String]
      #   This feature name.
      #
      # @api public
      def feature_name
        feature.name
      end

      # @return [Array<GherkinRuby::AST::Scenario>]
      #   The parsed scenarios for this runner's feature.
      #
      # @api public
      def scenarios
        feature.scenarios
      end

      # Runs this feature.
      #
      # @return [true, false]
      #   Whether the run was successful or not.
      #
      # @api public
      def run
        Spinach.hooks.run_before_feature(feature)

        if Spinach.find_step_definitions(feature_name)
          run_scenarios!
        else
          undefined_steps!
        end

        Spinach.hooks.run_after_feature(feature)

        # FIXME The feature & scenario runners should have the same structure.
        #       They should either both return inverted failure or both return
        #       raw success.
        !@failed
      end

      private

      def feature_tags
        if feature.respond_to?(:tags)
          feature.tags
        else
          []
        end
      end

      def run_scenarios!
        scenarios_to_run.each do |scenario|
          success = ScenarioRunner.new(scenario).run
          @failed = true unless success

          break if Spinach.config.fail_fast && @failed
        end
      end

      def undefined_steps!
        Spinach.hooks.run_on_undefined_feature(feature)

        @failed = true
      end

      def scenarios_to_run
        feature.scenarios.select do |scenario|
          has_a_tag_that_will_be_run = TagsMatcher.match(feature_tags + scenario.tags)
          on_a_line_that_will_be_run = if feature.run_every_scenario?
                                         true
                                       else
                                         (scenario.lines & feature.lines_to_run).any?
                                       end

          has_a_tag_that_will_be_run && on_a_line_that_will_be_run
        end
      end
    end
  end
end
