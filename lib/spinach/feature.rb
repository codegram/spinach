module Spinach
  class Feature
    attr_accessor :line
    attr_accessor :name, :scenarios, :tags
    attr_accessor :background

    def initialize
      @scenarios = []
      @tags = []
    end

    def background_steps
      @background.nil? ? [] : @background.steps
    end

  end
end
