require 'hooks'

module Spinach
  class Runner
    # A Scenario Runner handles a particular scenario run.
    #
    class ScenarioRunner
      attr_reader :feature_name, :data

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
      def initialize(feature_name, data)
        @feature_name = feature_name
        @data = data
      end

      def steps
        @steps ||= data['steps']
      end

      # @return [Feature]
      #   The feature object used to run this scenario.
      #
      # @api public
      def feature_steps
        @feature_steps ||= Spinach.find_feature_steps(feature_name).new
      end

      # Runs this scenario
      # @return [True, False]
      #   true if this scenario succeeded, false if not
      def run
        run_hook :before_run, data
        feature_steps.run_hook :before_scenario, data
        steps.each do |step|
          feature_steps.run_hook :before_step, step
          unless @exception
            begin
              step_location = feature_steps.execute_step(step['name'])
              run_hook :on_successful_step, step, step_location
            rescue *Spinach.config[:failure_exceptions] => e
              @exception = e
              run_hook :on_failed_step, step, @exception, step_location
            rescue Spinach::StepNotDefinedException => e
              @exception = e
              run_hook :on_undefined_step, step, @exception
            rescue Exception => e
              @exception = e
              run_hook :on_error_step, step, @exception, step_location
            end
          else
            run_hook :on_skipped_step, step
          end
          feature_steps.run_hook :after_step, step
        end
        feature_steps.run_hook :after_scenario, data
        run_hook :after_run, data
        !@exception
      end
    end
  end
end
