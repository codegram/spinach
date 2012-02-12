module Spinach
  class Runner
    class StepRunner
      def initialize(step, context)
        @step = step
        @success = true
        @context = context
      end

      def run(previous_step_success)
        hooks.run_before_step @step
        execute unless skip?(previous_step_success)
        hooks.run_after_step @step
      end

      def skip?(previous_step_success)
        unless previous_step_success
          hooks.run_on_skipped_step @step
        end
        !previous_step_success
      end

      # Runs a particular step.
      #
      # @param [Gherkin::AST::Step] step
      #   The step to be run.
      #
      # @api semipublic
      def execute
        @context.execute(@step)
        hooks.run_on_successful_step @step, location
      rescue *Spinach.config[:failure_exceptions] => exception
        @success = false
        hooks.run_on_failed_step @step, exception, location
      rescue Spinach::StepNotDefinedException => exception
        @success = false
        hooks.run_on_undefined_step @step, exception
      rescue Exception => exception
        @success = false
        hooks.run_on_error_step @step, exception, location
      end

      def hooks
        Spinach.hooks
      end

      def success?
        @success
      end

      def location
        @context.step_location_for(@step.name)
      end
    end
  end
end
