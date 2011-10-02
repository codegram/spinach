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

    attr_reader :current_feature, :current_scenario

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

    # Receives this hook when a feature reaches its end
    #
    def end(success)
      raise 'You need to define the `end` method in your reporter!'
    end

    def bind
      reporter = self
      Runner.after_run{|status| reporter.end(status)}
      Runner::Feature.before_run{|name| reporter.feature(name)}
      Runner::Scenario.before_run{ |data| reporter.scenario(data)}
      Runner::Scenario.on_successful_step{ |step|
        reporter.step(step, :success)
      }
      Runner::Scenario.on_failed_step{ |step, failure|
        reporter.step(step, :failure, failure)
      }
      Runner::Scenario.on_error_step{ |step, failure|
        reporter.step(step, :error, failure)
      }
      Runner::Scenario.on_skipped_step{ |step|
        reporter.step(step, :skip)
      }
    end

  end
end

require_relative 'reporter/stdout'
