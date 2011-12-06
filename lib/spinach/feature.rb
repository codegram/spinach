module Spinach
  class Feature
    attr_accessor :line
    attr_accessor :name, :scenarios
    attr_accessor :background

    def initialize
      @scenarios = []
    end

    def background_steps
      @background.nil? ? [] : @background.steps
    end

  end
end
