# encoding: utf-8
require 'colorize'

module Spinach
  # Spinach reporter collects information from Runner hooks and outputs the
  # results
  #
  class Reporter
    # Initialize a reporter with an empty error container.
    def initialize(options = {})
      @errors = []
      @options = options
      @undefined_steps = []
      @failed_steps = []
      @error_steps = []
    end

    # A Hash with options for the reporter
    #
    attr_accessor :options

    attr_accessor :current_feature, :current_scenario

    attr_reader :undefined_steps, :failed_steps, :error_steps

    # Receives this hook when a feature is invoked
    # @param [Hash] data
    #   the feature data
    #
    def feature(data)
      raise 'You need to define the `feature` method in your reporter!'
    end

    # Receives this hook when a scenario is invoked
    # @param [Hash] data
    #   the scenario data
    #
    def scenario(data)
      raise 'You need to define the `scenario` method in your reporter!'
    end

    # Receives this hook when a step is invoked
    # @param [Hash] step
    #   the step data
    # @param [Symbol] result
    #   the step name and its finishing state. May be :success or :failure
    #
    def step(step, result)
      raise 'You need to define the `step` method in your reporter!'
    end

    def bind
      Runner.after_run method(:_after_run)
      Runner::Feature.before_run method(:_before_feature_run)
      Runner::Feature.after_run method(:_after_feature_run)
      Runner::Scenario.before_run method(:_before_scenario_run)
      Runner::Scenario.after_run method(:_after_scenario_run)
      Runner::Scenario.on_successful_step method(:_on_successful_step)
      Runner::Scenario.on_failed_step method(:_on_failed_step)
      Runner::Scenario.on_error_step method(:_on_error_step)
      Runner::Scenario.on_skipped_step method(:_on_skipped_step)
    end

    def _after_run(status)
      self.end(status)
    end

    def _before_feature_run(data)
      feature(data)
      current_feature = data
    end

    def _after_feature_run(data)
      current_feature = nil
    end

    def _before_scenario_run(data)
      scenario(data)
      current_scenario = data
    end

    def _after_scenario_run(data)
      after_scenario
      current_scenario = nil
    end

    def _on_successful_step(step)
      step(step, :success)
    end

    def _on_failed_step(step, failure)
      step(step, :failure, failure)
    end

    def _on_error_step(step, failure)
      step(step, :error, failure)
    end

    def _on_skipped_step(step)
      step(step, :skip)
    end

  end
end

require_relative 'reporter/stdout'
