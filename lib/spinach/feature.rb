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
end
