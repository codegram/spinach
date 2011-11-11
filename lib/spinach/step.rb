module Spinach
  class Step
    attr_accessor :line
    attr_accessor :name, :scenario

    def initialize(scenario)
      @scenario = scenario
    end
  end
end
