module Spinach
  class Scenario
    attr_accessor :line
    attr_accessor :name, :steps, :tags, :feature

    def initialize(feature)
      @feature   = feature
      @scenarios = []
      @tags      = []
    end
  end
end
