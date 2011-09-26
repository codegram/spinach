require 'minitest/spec'
MiniTest::Spec.new nil

module Spinach
  # The feature class is the class where all the features must inherit from.
  #
  class Feature
    extend DSL
    include MiniTest::Assertions

    def before; end;
    def after; end;

    def self.inherited(base)
      Spinach.features << base
    end
  end
end
