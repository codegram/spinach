require_relative 'hookable'

module Spinach
  # The hooks class is a subscription/notification mechanism that allows you to
  # hook into signals provided by the runner and perform certain actions on
  # it.
  #
  # @example
  #   Spinach.hooks.before_run do
  #     # Runs before the entire spinach execution
  #   end
  #
  #   Spinach.hooks.before_scenario do |scenario_data|
  #     # Runs before every scenario and passes a hash of the parsed scenario
  #     # data to the block as argument
  #   end
  #
  #   Spinach.hooks.on_failed_step do |step_data|
  #     # Runs before every failed stepand passes a hash of the parsed step
  #     # data to the block as argument
  #   end
  class Hooks
    include Hookable

    # Runs before the entire spinach run
    #
    # @example
    #   Spinach.before_run do
    #     # Whatever
    #   end
    define_hook :before_run

    # Runs after the entire spinach run
    #
    # @example
    #   Spinach.after_run do |status|
    #     # status is true when the run is successful, false otherwise
    #   end
    define_hook :after_run

    # Runs before every feature,
    #
    # @example
    #   Spinach.before_feature do |feature_data|
    #     # feature_data is a hash of the parsed feature data
    #   end
    define_hook :before_feature

    # Runs after every feature
    #
    # @example
    #   Spinach.after_feature do |feature_data|
    #     # feature_data is a hash of the parsed feature data
    #   end
    define_hook :after_feature

    # Runs when an undefined feature is found
    #
    # @example
    #   Spinach.on_undefined_feature do |feature_data, exception|
    #     # feature_data is a hash of the parsed feature data
    #     # exception contains the thrown exception
    #   end
    define_hook :on_undefined_feature

    # Runs before every scenario
    #
    # @example
    #   Spinach.before_scenario do |scenario_data|
    #     # feature_data is a hash of the parsed scenario data
    #   end
    define_hook :before_scenario

    # Runs after every scenario
    #
    # @example
    #   Spinach.after_scenario do |scenario_data|
    #     # feature_data is a hash of the parsed scenario data
    #   end
    define_hook :after_scenario

    # Runs before every step execution
    #
    # @example
    #   Spinach.before_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    define_hook :before_step

    # Runs after every step execution
    #
    # @example
    #   Spinach.before_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    define_hook :after_step

    # Runs after every successful step execution
    #
    # @example
    #   Spinach.on_successful_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    define_hook :on_successful_step

    # Runs after every failed step execution
    #
    # @example
    #   Spinach.on_failed_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    define_hook :on_failed_step

    # Runs after every step execution that raises an exception
    #
    # @example
    #   Spinach.on_error_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    define_hook :on_error_step

    # Runs every time a step which is not defined is called
    #
    # @example
    #   Spinach.on_undefined_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    define_hook :on_undefined_step

    # Runs every time a step is skipped because there has been an unsuccessful
    # one just before.
    #
    # @example
    #   Spinach.on_undefined_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    define_hook :on_skipped_step

  end

end
