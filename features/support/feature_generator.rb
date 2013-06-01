module Integration
  class FeatureGenerator
    class << self
      include Filesystem

      def success_feature
        feature= success_scenario_title + success_scenario
        write_file 'features/success_feature.feature', feature
        steps = success_step_class_str + success_step + "\nend"
        write_file 'features/steps/success_feature.rb', steps
        "features/success_feature.feature"
      end

      def failure_feature_with_two_scenarios
        feature = failure_feature_title + failure_sceario + success_scenario
        write_file(failure_filename, feature)
        steps = failure_step + success_step + "\nend"
        write_file(failure_step_filename, steps)
        failure_filename
      end

      def failure_feature
        feature = failure_feature_title + failure_sceario
        write_file failure_filename, feature
        write_file failure_step_filename, failure_step+"\nend"
        failure_filename
      end

      private

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
