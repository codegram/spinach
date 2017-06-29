module Spinach
  class Scenario
    attr_accessor :lines
    attr_accessor :name, :steps, :tags, :feature

    def initialize(feature)
      @feature = feature
      @steps   = []
      @tags    = []
      @lines   = []
    end
  end
end
