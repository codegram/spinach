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
        run_hook :before_run, name
        feature.run_hook :before_scenario, name
        steps.each do |step|
          feature.run_hook :before_step, step
          unless @exception
            begin
              feature.execute_step(step['name'])
              run_hook :on_successful_step, step
            rescue MiniTest::Assertion => e
              @exception = e
              run_hook :on_failed_step, step, @exception
            rescue Spinach::StepNotDefinedException => e
              @exception = e
              run_hook :on_undefined_step, step, @exception
            rescue StandardError => e
              @exception = e
              run_hook :on_error_step, step, @exception
            end
          else
            run_hook :on_skipped_step, step
          end
          feature.run_hook :after_step, step
        end
        feature.run_hook :after_scenario, name
        run_hook :after_run, name
        !@exception
      end
    end
  end
end
