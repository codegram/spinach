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
      @pending_steps = []
    end

    # A Hash with options for the reporter
    #
    attr_reader :options, :current_feature, :current_scenario

    attr_reader :pending_steps, :undefined_steps, :failed_steps, :error_steps, :undefined_features, :successful_steps

    # Hooks the reporter to the runner endpoints
    def bind
      Spinach.hooks.tap do |hooks|
        hooks.before_run { |*args| before_run(*args) }
        hooks.after_run { |*args| after_run(*args) }
        hooks.before_feature { |*args| before_feature_run(*args) }
        hooks.after_feature { |*args| after_feature_run(*args) }
        hooks.on_undefined_feature { |*args| on_feature_not_found(*args) }
        hooks.before_scenario { |*args| before_scenario_run(*args) }
        hooks.around_scenario { |*args, &block| around_scenario_run(*args, &block) }
        hooks.after_scenario { |*args| after_scenario_run(*args) }
        hooks.on_successful_step { |*args| on_successful_step(*args) }
        hooks.on_undefined_step { |*args| on_undefined_step(*args) }
        hooks.on_pending_step { |*args| on_pending_step(*args) }
        hooks.on_failed_step { |*args| on_failed_step(*args) }
        hooks.on_error_step { |*args| on_error_step(*args) }
        hooks.on_skipped_step { |*args| on_skipped_step(*args) }

        hooks.before_feature { |*args| set_current_feature(*args) }
        hooks.after_feature { |*args| clear_current_feature(*args) }
        hooks.before_scenario { |*args| set_current_scenario(args.first) }
        hooks.after_scenario { |*args| clear_current_scenario(args.first) }
      end
    end

    def before_run(*args); end;
    def after_run(*args); end;
    def before_feature_run(*args); end
    def after_feature_run(*args); end
    def on_feature_not_found(*args); end
    def before_scenario_run(*args); end
    def around_scenario_run(*args)
      yield
    end
    def after_scenario_run(*args); end
    def on_successful_step(*args); end;
    def on_failed_step(*args); end;
    def on_error_step(*args); end;
    def on_undefined_step(*args); end;
    def on_pending_step(*args); end;
    def on_skipped_step(*args); end;

    # Stores the current feature
    #
    # @param [Feature]
    #   The feature.
    def set_current_feature(feature)
      @current_feature = feature
    end

    # Clears this current feature
    def clear_current_feature(*args)
      @current_feature = nil
    end

    # Stores the current scenario
    #
    # @param [Hash]
    #   the data for this scenario
    def set_current_scenario(scenario)
      @current_scenario = scenario
    end

    # Clears this current scenario
    def clear_current_scenario(*args)
      @current_scenario = nil
    end
  end
end

require_relative 'reporter/stdout'
require_relative 'reporter/progress'
require_relative 'reporter/failure_file'
