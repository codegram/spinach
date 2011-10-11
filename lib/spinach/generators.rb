module Spinach
  # Spinach generators are a set of utils that auto-generates example features
  # given some parsed feature data.
  #
  module Generators
    # Binds the feature generator to the "feature not found" hook
    def self.bind
      Spinach::Runner::FeatureRunner.when_not_found do |data|
        Spinach::Generators.generate_feature(data)
      end
    end

    # Generates a feature given a parsed feature data
    #
    # @param [Hash] data
    #   the parsed feature data
    def self.generate_feature(data)
      FeatureGenerator.new(data).store
    rescue FeatureGeneratorException => e
      $stderr.puts e
    end
  end
end

require_relative 'generators/feature_generator'
require_relative 'generators/step_generator'
