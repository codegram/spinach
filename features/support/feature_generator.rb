module Integration
  class FeatureGenerator
    class << self
      include Filesystem

      # Generate a feature with 1 scenario that should pass
      #
      # @return feature_filename
      #   The feature file name
      #
      # @api private
      def success_feature
        feature = success_scenario_title + success_scenario
        steps   = success_step_class_str + success_step + "\nend"
        write_feature 'features/success_feature.feature', feature,
          'features/steps/success_feature.rb', steps
      end

      # Generate a feature with 1 scenario that has a pending step in between
      #
      # @return feature_filename
      #   The feature file name
      #
      # @api private
      def pending_feature_with_multiple_scenario
        feature_str = pending_feature_str + "\n" + success_scenario
        steps = pending_step_class_str + pending_step + "\n" + failure_step_definition + success_step + "\nend"
        write_feature 'features/success_feature.feature', feature_str,
          'features/steps/pending_feature_with_multiple_scenario.rb', steps
      end

      # Generate a feature that has 2 scenarios. The first one should
      # pass and the second one should fail
      #
      # @return feature_filename
      #   The feature file name
      #
      # @api private
      def failure_feature_with_two_scenarios
        feature = failure_feature_title + failure_scenario + success_scenario
        steps = failure_step + success_step + "\nend"
        write_feature failure_filename, feature,
          failure_step_filename, steps
      end

      # Generate a tagged feature that has 2 tagged scenarios.
      # 1 should pass, and 1 should fail.
      #
      # @return feature_filename
      #   The feature file name
      #
      # @api private
      def tagged_failure_feature_with_two_scenarios
        feature = "@feature\n" +
          failure_feature_title +
          "  @failing" +
          failure_scenario + "\n" +
          "  @passing\n" +
          "  " + success_scenario

        steps = failure_step +
          success_step + "\n" +
          "end"

        write_feature(
          failure_filename, feature,
          failure_step_filename, steps
        )
      end

      # Generate a feature with 1 scenario that should fail
      #
      # @return feature_filename
      #   The feature file name
      #
      # @api private
      def failure_feature
        feature = failure_feature_title + failure_scenario
        write_feature failure_filename, feature,
          failure_step_filename, failure_step + "\nend"
      end

      private

      # Write feature file and its associated step file
      # @param feature_file
      #   The name of the feature file to be written to
      # @param feature
      #   The string to be written into the feature file
      # @param step_file
      #   The name of the step ruby file to be written to
      # @param steps
      #   The string to be written into the step file
      #
      # @return feature_filename
      #   The feature file name
      #
      # @api private
      def write_feature(feature_file, feature, step_file, steps)
        write_file(feature_file, feature)
        write_file(step_file, steps)
        feature_file
      end

      def failure_step
        %Q|class AFailureFeature < Spinach::FeatureSteps
      feature "A failure feature"
      #{failure_step_definition}
      |
      end

      def failure_step_definition
      'step "I fail" do
        true.must_equal false
      end'
      end

      def pending_feature_str
        "Feature: A feature with pending steps
        Scenario: This is scenario will be pending
        When this is a pending step
    Then I fail"
      end

      def success_scenario
        'Scenario: This is scenario will succeed
    Then I succeed'
      end

      def success_scenario_title
        "Feature: A success feature\n\n"
      end

      def success_step
        '
      step "I succeed" do
      end'
      end

      def pending_step_class_str
        %Q|class ApendingFeature < Spinach::FeatureSteps
        feature "A feature with pending steps"\n\n|
      end

      def pending_step
        '
      step "this is a pending step" do
        pending "to be implemented"
      end'
      end

      def success_step_class_str
        %Q|class ASuccessFeature < Spinach::FeatureSteps
        feature "A success feature"\n\n|
      end

      def failure_step_filename
        'features/steps/failure_feature.rb'
      end

      def failure_filename
        "features/failure_feature.feature"
      end

      def failure_feature_title
        "Feature: A failure feature\n\n"
      end

      def failure_scenario
        "
  Scenario: This is scenario will fail
    Then I fail\n"
      end
    end
  end
end
