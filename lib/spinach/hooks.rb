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
    #   Spinach.hooks.before_run do
    #     # Whatever
    #   end
    hook :before_run

    # Runs after the entire spinach run
    #
    # @example
    #   Spinach.hooks.after_run do |status|
    #     # status is true when the run is successful, false otherwise
    #   end
    hook :after_run

    # Runs before every feature,
    #
    # @example
    #   Spinach.hooks.before_feature do |feature_data|
    #     # feature_data is a hash of the parsed feature data
    #   end
    hook :before_feature

    # Runs after every feature
    #
    # @example
    #   Spinach.hooks.after_feature do |feature_data|
    #     # feature_data is a hash of the parsed feature data
    #   end
    hook :after_feature

    # Runs when an undefined feature is found
    #
    # @example
    #   Spinach.hooks.on_undefined_feature do |feature_data, exception|
    #     # feature_data is a hash of the parsed feature data
    #     # exception contains the thrown exception
    #   end
    hook :on_undefined_feature

    # Runs before every scenario
    #
    # @example
    #   Spinach.hooks.before_scenario do |scenario_data|
    #     # feature_data is a hash of the parsed scenario data
    #   end
    hook :before_scenario

    # Runs after every scenario
    #
    # @example
    #   Spinach.hooks.after_scenario do |scenario_data|
    #     # feature_data is a hash of the parsed scenario data
    #   end
    hook :after_scenario

    # Runs before every step execution
    #
    # @example
    #   Spinach.hooks.before_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    hook :before_step

    # Runs after every step execution
    #
    # @example
    #   Spinach.hooks.before_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    hook :after_step

    # Runs after every successful step execution
    #
    # @example
    #   Spinach.hooks.on_successful_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    hook :on_successful_step

    # Runs after every failed step execution
    #
    # @example
    #   Spinach.hooks.on_failed_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    hook :on_failed_step

    # Runs after every step execution that raises an exception
    #
    # @example
    #   Spinach.hooks.on_error_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    hook :on_error_step

    # Runs every time a step which is not defined is called
    #
    # @example
    #   Spinach.hooks.on_undefined_step do |step_data, location|
    #     # step_data contains a hash with this step's data
    #     # step_location contains a string indication this step definition's
    #     # location
    #   end
    hook :on_undefined_step

    # Runs every time a step is skipped because there has been an unsuccessful
    # one just before.
    #
    # @example
    #   Spinach.hooks.on_undefined_step do |step_data|
    #     # step_data contains a hash with this step's data
    #   end
    hook :on_skipped_step

    # Runs before running a scenario with a particular tag
    #
    # @param [String] tag
    #   the tag to match
    #
    # @example
    #   Spinach.hooks.on_tag('javascript') do
    #     # change capybara driver
    #   end
    def on_tag(tag)
      before_scenario do |data|
        next unless data["tags"]
        tags = data["tags"].map{ |tag| tag["name"] }
        yield(data) if tags.include? tag.to_s
      end
    end
  end
end
