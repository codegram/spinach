require_relative 'spinach/version'
require_relative 'spinach/runner'
require_relative 'spinach/parser'
require_relative 'spinach/dsl'
require_relative 'spinach/feature'

module Spinach
  @@features = []

  def self.features
    @@features
  end

  def self.find_feature(name)
    @@features.detect do |feature|
      feature.feature_name == name
    end
  end
end
