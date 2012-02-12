require_relative 'scenario_runner_mutex'
require_relative 'step_runner'

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
        step_definitions = step_definitions_klass.new
        @steps ||=(feature.background_steps + @scenario.steps).map do |step|
          StepRunner.new(step, step_definitions)
        end
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
        scenario_runner_mutex = ScenarioRunnerMutex.new

        hooks.run_before_scenario @scenario
        scenario_runner_mutex.deactivate

        hooks.run_around_scenario @scenario do
          scenario_runner_mutex.activate
          run_scenario_steps
        end

        raise "around_scenario hooks *must* yield" if !scenario_runner_mutex.active? && success?
        hooks.run_after_scenario @scenario

        !!success?
      end

      def hooks
        Spinach.hooks
      end

      def run_scenario_steps
        previous_step_success = true
        steps.each do |step|
          step.run(previous_step_success)
          previous_step_success = step.success?
        end
      end

      def success?
        steps.all? do |step|
          step.success?
        end
      end
    end
  end
end
