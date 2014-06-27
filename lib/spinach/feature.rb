module Spinach
  class Feature
    attr_accessor :filename, :line
    attr_accessor :name, :scenarios, :tags
    attr_accessor :background
    attr_accessor :description

    def initialize
      @scenarios = []
      @tags = []
    end

    def background_steps
      @background.nil? ? [] : @background.steps
    end

    def line=(value)
      @line = value.to_i if value
    end

  end
end
