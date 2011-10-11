module Spinach
  module Generators
    def self.bind
      Spinach::Runner::Feature.when_not_found do |data|
        Spinach::Generators.generate_feature(data)
      end
    end

    def self.generate_feature(data)
      FeatureGenerator.new(data).store
    rescue FeatureGeneratorException => e
      $stderr.puts e
    end
  end
end

require_relative 'generators/feature_generator'
require_relative 'generators/step_generator'
