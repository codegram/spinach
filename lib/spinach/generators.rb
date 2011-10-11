module Spinach
  module Generators
    def self.bind
      Spinach::Runner::Feature.when_not_found method(:generate_feature)
    end

    def self.generate_feature(data)
      FeatureGenerator.new(data).store
    end
  end
end

require_relative 'generators/feature_generator'
require_relative 'generators/step_generator'
