require_relative 'spinach/version'
require_relative 'spinach/config'
require_relative 'spinach/support'
require_relative 'spinach/exceptions'
require_relative 'spinach/runner'
require_relative 'spinach/parser'
require_relative 'spinach/dsl'
require_relative 'spinach/feature_steps'
require_relative 'spinach/reporter'
require_relative 'spinach/cli'
require_relative 'spinach/generators'

# Spinach is a BDD framework leveraging the great Gherkin language. This
# language is the one used defining features in Cucumber, the BDD framework
# Spinach is inspired upon.
#
# Its main design goals are:
#
#   * No magic: All features are implemented using normal Ruby classes.
#   * Reusability: Steps are methods, so they can be reused using modules, a
#     common, normal practice among rubyists.
#   * Proper encapsulation: No conflicts between steps from different
#     scenarios.
#
module Spinach
  @@feature_steps = []

  # @return [Array<FeatureSteps>]
  #   All the registered features.
  #
  # @api public
  def self.feature_steps
    @@feature_steps
  end

  # Resets Spinach to a pristine state, as if no feature was ever registered.
  # Mostly useful in Spinach's own testing.
  #
  # @api semipublic
  def self.reset_feature_steps
    @@feature_steps = []
  end

  # Finds a feature given a feature name.
  #
  # @param [String] name
  #   The feature name.
  #
  # @return [FeatureSteps]
  #   the {FeatureSteps} class for the given feature name
  #
  # @api public
  def self.find_feature_steps(name)
    klass = Spinach::Support.camelize(name)
    feature_steps.detect do |feature|
      feature.feature_name.to_s == name.to_s ||
      feature.name == klass
    end || raise(Spinach::FeatureStepsNotFoundException, [klass, name])
  end
end
