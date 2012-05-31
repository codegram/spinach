module Spinach
  class Runner
    # A Scenario Runner handles a particular scenario run.
    #
    class ScenarioRunner
      # @param [Gherkin::AST::Scenario] scenario
      #   The scenario.
      #
      # @api public
      def initialize(scenario)
        @scenario = scenario
      end

      # @return [Gherkin::AST::Feature>]
      #   The feature containing the scenario.
      #
      # @api public
      def feature
        @scenario.feature
      end

      # @return [Array<Gherkin::AST::Step>]
      #   An array of steps.
      #
      # @api public
      def steps
        feature.background_steps + @scenario.steps
      end

      # @return [FeatureSteps]
      #   The step definitions for the current feature.
      #
      # @api public
      def step_definitions
        @step_definitions ||= Spinach.find_step_definitions(feature.name).new
      end

      # Runs the scenario, capturing any exception, and running the
      # corresponding hooks.
      #
      # @return [true, false]
      #   Whether the scenario succeeded or not.
      #
      # @api public
      def run
        Spinach.hooks.run_before_scenario @scenario, step_definitions
        scenario_run = false
        Spinach.hooks.run_around_scenario @scenario, step_definitions do
          scenario_run = true
          steps.each do |step|
            Spinach.hooks.run_before_step step, step_definitions

            if @exception
              Spinach.hooks.run_on_skipped_step step, step_definitions
            else
              run_step(step)
            end

            Spinach.hooks.run_after_step step, step_definitions
          end
        end
        raise "around_scenario hooks *must* yield" if !scenario_run && !@exception
        Spinach.hooks.run_after_scenario @scenario, step_definitions
        !@exception
      end

      # Runs a particular step.
      #
      # @param [Gherkin::AST::Step] step
      #   The step to be run.
      #
      # @api semipublic
      def run_step(step)
        step_location = step_definitions.step_location_for(step.name)
        step_definitions.execute(step)
        Spinach.hooks.run_on_successful_step step, step_location, step_definitions
      rescue *Spinach.config[:failure_exceptions] => e
        @exception = e
        Spinach.hooks.run_on_failed_step step, @exception, step_location, step_definitions
      rescue Spinach::StepNotDefinedException => e
        @exception = e
        Spinach.hooks.run_on_undefined_step step, @exception, step_definitions
      rescue Spinach::StepPendingException => e
        e.step = step
        @exception = e
        Spinach.hooks.run_on_pending_step step, @exception
      rescue Exception => e
        @exception = e
        Spinach.hooks.run_on_error_step step, @exception, step_location, step_definitions
      end

    end
  end
end
