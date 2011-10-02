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

    attr_reader :undefined_steps, :failed_steps, :error_steps

    # Receives this hook when a feature is invoked
    # @param [String] name
    #   the feature name
    #
    def feature(name)
      raise 'You need to define the `feature` method in your reporter!'
    end

    # Receives this hook when a scenario is invoked
    # @param [String] name
    #   the scenario name
    #
    def scenario(name)
      raise 'You need to define the `scenario` method in your reporter!'
    end

    # Receives this hook when a step is invoked
    # @param [String] name
    #   the scenario name
    # @param [Symbol] result
    #   the step name and its finishing state. May be :success or :failure
    #
    def step(keyword, name, result)
      raise 'You need to define the `step` method in your reporter!'
    end

    # Receives this hook when a feature reaches its end
    #
    def end(success)
      raise 'Abstract method!'
      raise 'You need to define the `end` method in your reporter!'
    end

    def bind
      reporter = self
      Runner.after_run{|status| reporter.end(status)}
      Runner::Feature.before_run{|name| reporter.feature(name)}
      Runner::Scenario.before_run{ |name| reporter.scenario(name)}
      Runner::Scenario.on_successful_step{ |keyword, name|
        reporter.step(keyword, name, :success)
      }
      Runner::Scenario.on_failed_step{ |keyword, name, failure|
        reporter.step(keyword, name, :failure, failure)
      }
      Runner::Scenario.on_error_step{ |keyword, name, failure|
        reporter.step(keyword, name, :error, failure)
      }
      Runner::Scenario.on_skipped_step{ |keyword, name|
        reporter.step(keyword, name, :skip)
      }
    end

  end
end

require_relative 'reporter/stdout'
