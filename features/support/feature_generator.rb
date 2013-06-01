module Integration
  class FeatureGenerator
    class << self
      include Filesystem

      def success_feature
        write_file('features/success_feature.feature', """
Feature: A success feature

  Scenario: This is scenario will succeed
    Then I succeed
                   """)
        write_file('features/steps/success_feature.rb',
                   'class ASuccessFeature < Spinach::FeatureSteps
      feature "A success feature"
      Then "I succeed" do
      end
     end')
        "features/success_feature.feature"

      end

      def failure_feature
        write_file('features/failure_feature.feature', """
Feature: A failure feature

  Scenario: This is scenario will fail
    Then I fail
                   """)
        write_file('features/steps/failure_feature.rb',
                   'class AFailureFeature < Spinach::FeatureSteps
      feature "A failure feature"
      Then "I fail" do
        true.must_equal false
      end
     end')
        "features/failure_feature.feature"
      end
    end
  end
end
