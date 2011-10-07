require 'hooks'

module Spinach
  class Runner
    # A Scenario Runner handles a particular scenario run.
    #
    class Scenario
      attr_reader :feature, :feature_name, :data

      include Hooks

      define_hook :before_run
      define_hook :on_successful_step
      define_hook :on_failed_step
      define_hook :on_error_step
      define_hook :on_undefined_step
      define_hook :on_skipped_step
      define_hook :after_run

      # @param [Feature] feature
      #   The feature that contains the steps.
      #
      # @param [Hash] data
      #   The parsed feature data.
      #
      # @api public
      def initialize(feature_name, feature, data)
        @feature_name = feature_name
        @data = data
        @feature = feature
      end

      def steps
        @steps ||= data['steps']
      end

      # Runs this scenario
      # @return [True, False]
      #   true if this scenario succeeded, false if not
      def run
        run_hook :before_run, data
        feature.run_hook :before_scenario, data
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
        feature.run_hook :after_scenario, data
        run_hook :after_run, data
        !@exception
      end
    end
  end
end
