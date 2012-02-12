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
        @step_definitions ||= step_definitions_klass.new
      end

      def step_definitions_klass
        Spinach.find_step_definitions(feature.name)
      end

      # Runs the scenario, capturing any exception, and running the
      # corresponding hooks.
      #
      # @return [true, false]
      #   Whether the scenario succeeded or not.
      #
      # @api public
      def run
        hooks.run_before_scenario @scenario
        scenario_mutex.deactivate
        hooks.run_around_scenario @scenario do
          scenario_mutex.activate
          run_scenario_steps
        end
        raise "around_scenario hooks *must* yield" if !scenario_mutex.active? && !@exception
        hooks.run_after_scenario @scenario
        !@exception
      end

      def hooks
        Spinach.hooks
      end

      def scenario_mutex
        @scenario_mutex ||= ScenarioMutex.new
      end

      def run_scenario_steps
        steps.each do |step|
          run_step_with_hooks(step)
        end
      end

      def run_step_with_hooks(step)
        hooks.run_before_step step
        run_step(step) unless skip_step?(step)
        hooks.run_after_step step
      end

      def skip_step?(step)
        if @exception
          hooks.run_on_skipped_step step
          return true
        end
        return false
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
        hooks.run_on_successful_step step, step_location
      rescue *Spinach.config[:failure_exceptions] => e
        @exception = e
        hooks.run_on_failed_step step, @exception, step_location
      rescue Spinach::StepNotDefinedException => e
        @exception = e
        hooks.run_on_undefined_step step, @exception
      rescue Exception => e
        @exception = e
        hooks.run_on_error_step step, @exception, step_location
      end

      class ScenarioMutex
        def initialize
          @running = false
        end

        def deactivate
          @running = false
        end

        def activate
          @running = true
        end

        def active?
          !!@running
        end
      end
    end
  end
end
