module Spinach
  class Runner
    # A Scenario Runner handles a particular scenario run.
    #
    class ScenarioRunner
      attr_reader :feature_name, :data

      # @param [String] feature_name
      #   The feature name
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

      # @return [FeatureSteps]
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
        Spinach.hooks.run_before_scenario data
        steps.each do |step|
          Spinach.hooks.run_before_step step
          unless @exception
            begin
              step_location = feature_steps.execute_step(step['name'])
              Spinach.hooks.run_on_successful_step step, step_location
            rescue *Spinach.config[:failure_exceptions] => e
              @exception = e
              Spinach.hooks.run_on_failed_step step, @exception, step_location
            rescue Spinach::StepNotDefinedException => e
              @exception = e
              Spinach.hooks.run_on_undefined_step step, @exception
            rescue Exception => e
              @exception = e
              Spinach.hooks.run_on_error_step step, @exception, step_location
            end
          else
            Spinach.hooks.run_on_skipped_step step
          end
          Spinach.hooks.run_after_step step
        end
        Spinach.hooks.run_after_scenario data
        !@exception
      end
    end
  end
end
