module Spinach
  class Scenario
    attr_accessor :line
    attr_accessor :name, :steps, :tags

    def initialize
      @scenarios = []
      @tags = []
    end
  end
end
