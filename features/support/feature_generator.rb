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
        feature= success_scenario_title + success_scenario
        steps = success_step_class_str + success_step + "\nend"
        write_feature 'features/success_feature.feature', feature,
          'features/steps/success_feature.rb', steps
      end

      # Generate a feature that has 2 scenarios. The first one should
      # pass and the second one should fail
      #
      # @return feature_filename
      #   The feature file name
      #
      # @api private
      def failure_feature_with_two_scenarios
        feature = failure_feature_title + failure_sceario + success_scenario
        steps = failure_step + success_step + "\nend"
        write_feature failure_filename, feature,
          failure_step_filename, steps
      end

      # Generate a feature with 1 scenario that should fail
      #
      # @return feature_filename
      #   The feature file name
      #
      # @api private
      def failure_feature
        feature = failure_feature_title + failure_sceario
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
        'class AFailureFeature < Spinach::FeatureSteps
      feature "A failure feature"
      Then "I fail" do
        true.must_equal false
      end'
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

      def failure_sceario
        """
  Scenario: This is scenario will fail
    Then I fail
        """
      end
    end
  end
end
