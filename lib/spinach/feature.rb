require 'minitest'
require 'minitest/spec'
MiniTest::Spec.new nil

module Spinach
  class Feature
    extend DSL
    include MiniTest::Assertions

    def self.inherited(base)
      Spinach.features << base
    end
  end

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
