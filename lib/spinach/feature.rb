module Spinach
  class Feature
    attr_accessor :line
    attr_accessor :name, :scenarios

    def initialize
      @scenarios = []
    end
  end
end
