module Spinach
  class Feature
    attr_accessor :filename, :lines
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

    def lines=(value)
      @lines = value.map(&:to_i) if value
    end

    # Run the provided code for every step
    def each_step
      scenarios.each { |scenario| scenario.steps.each { |step| yield step } }
    end
  end
end
