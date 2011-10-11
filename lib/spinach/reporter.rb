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
      @undefined_features = []
      @successful_steps = []
      @undefined_steps = []
      @failed_steps = []
      @error_steps = []
    end

    # A Hash with options for the reporter
    #
    attr_reader :options

    attr_accessor :current_feature, :current_scenario

    attr_reader :undefined_steps, :failed_steps, :error_steps, :undefined_features, :successful_steps

    def bind
      runner.after_run method(:after_run)
      feature_runner.before_run method(:before_feature_run)
      feature_runner.after_run method(:after_feature_run)
      feature_runner.when_not_found method(:on_feature_not_found)
      scenario_runner.before_run method(:before_scenario_run)
      scenario_runner.after_run method(:after_scenario_run)
      scenario_runner.on_successful_step method(:on_successful_step)
      scenario_runner.on_undefined_step method(:on_undefined_step)
      scenario_runner.on_failed_step method(:on_failed_step)
      scenario_runner.on_error_step method(:on_error_step)
      scenario_runner.on_skipped_step method(:on_skipped_step)

      feature_runner.before_run method(:current_feature=)
      feature_runner.after_run method(:clear_current_feature)
      scenario_runner.before_run method(:current_scenario=)
      scenario_runner.after_run method(:clear_current_scenario)
    end

    def feature_runner; Runner::FeatureRunner; end
    def scenario_runner; Runner::ScenarioRunner; end
    def runner; Runner; end

    def after_run(*args); end;
    def before_feature_run(*args); end
    def after_feature_run(*args); end
    def on_feature_not_found(*args); end
    def before_scenario_run(*args); end
    def after_scenario_run(*args); end
    def on_successful_step(*args); end;
    def on_failed_step(*args); end;
    def on_error_step(*args); end;
    def on_undefined_step(*args); end;
    def on_skipped_step(*args); end;

    def clear_current_feature(*args)
      self.current_feature = nil
    end

    def clear_current_scenario(*args)
      self.current_scenario = nil
    end

  end
end

require_relative 'reporter/stdout'
