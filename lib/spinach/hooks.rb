require_relative 'hookable'

module Spinach
  # Spinach's hooks is a subscription mechanism to allow developers to define
  # certain callbacks given several Spinach signals, like running a feature,
  # executing a particular step and such.
  class Hooks
    include Hookable

    # Runs before the entire spinach run
    #
    # @example
    #   Spinach.before_run do
    #     # Whatever
    #   end
    hook :before_run

    # Runs after the entire spinach run
    #
    # @example
    #   Spinach.after_run do |status|
    #     # status is true when the run is successful, false otherwise
    #   end
    hook :after_run

    # Runs before every feature,
    #
    # @example
    #   Spinach.before_feature do |feature_data|
    #     # feature_data is a hash of the parsed feature data
    #   end
    hook :before_feature

    # Runs after every feature
    #
    # @example
    #   Spinach.after_feature do |feature_data|
    #     # feature_data is a hash of the parsed feature data
    #   end
    hook :after_feature

    # Runs when an undefined feature is found
    #
    # @example
    #   Spinach.on_undefined_feature do |feature_data, exception|
    #     # feature_data is a hash of the parsed feature data
    #     # exception contains the thrown exception
    #   end
    hook :on_undefined_feature

    # Runs before every scenario
    #
    # @example
    #   Spinach.before_scenario do |scenario_data|
    #     # feature_data is a hash of the parsed scenario data
    #   end
    hook :before_scenario

    # Runs after every scenario
    #
    # @example
    #   Spinach.after_scenario do |scenario_data|
    #     # feature_data is a hash of the parsed scenario data
    #   end
    hook :after_scenario

    # Runs before every step execution
    #
    # @example
    #   Spinach.before_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    hook :before_step

    # Runs after every step execution
    #
    # @example
    #   Spinach.before_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    hook :after_step

    # Runs after every successful step execution
    #
    # @example
    #   Spinach.on_successful_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    hook :on_successful_step

    # Runs after every failed step execution
    #
    # @example
    #   Spinach.on_failed_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    hook :on_failed_step

    # Runs after every step execution that raises an exception
    #
    # @example
    #   Spinach.on_error_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    hook :on_error_step

    # Runs every time a step which is not defined is called
    #
    # @example
    #   Spinach.on_undefined_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    hook :on_undefined_step

    # Runs every time a step is skipped because there has been an unsuccessful
    # one just before.
    #
    # @example
    #   Spinach.on_undefined_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    hook :on_skipped_step
  end
end
