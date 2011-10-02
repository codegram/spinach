require 'hooks'

module Spinach
  class Runner
    # A Scenario Runner handles a particular scenario run.
    #
    class Scenario
      attr_reader :name, :feature, :feature_name, :steps

      include Hooks

      define_hook :before_run
      define_hook :on_successful_step
      define_hook :on_failed_step
      define_hook :on_error_step
      define_hook :on_undefined_step
      define_hook :on_skipped_step
      define_hook :after_run

      # @param [Spinach::Feature] feature
      #   the feature that contains the steps
      #
      # @param [Hash] data
      #   the parsed feature data
      #
      def initialize(feature_name, feature, data)
        @feature_name = feature_name
        @name = data['name']
        @steps = data['steps']
        @feature = feature
      end

      # Runs this scenario
      # @return [Boolean]
      #   true if this scenario succeeded
      def run
        feature.run_hook :before_scenario, name
        steps.each do |step|
          keyword = step['keyword'].strip
          name = step['name'].strip
          line = step['line']
          feature.run_hook :before_step, keyword, name
          unless @failure
            begin
              feature.execute_step(name)
              run_hook :on_successful_step, keyword, name
            rescue MiniTest::Assertion => e
              @failure = [e, name, line, self]
              run_hook :on_failed_step, keyword, name, @failure
            rescue Spinach::StepNotDefinedException => e
              @failure = [e, name, line, self]
              run_hook :on_undefined_step, keyword, name, @failure
            rescue StandardError => e
              @failure = [e, name, line, self]
              run_hook :on_error_step, keyword, name, @failure
            end
          else
            run_hook :on_skipped_step, keyword, name
          end
          feature.run_hook :after_step, keyword, name
        end
        feature.run_hook :after_scenario, name
        !@failure
      end
    end
  end
end
