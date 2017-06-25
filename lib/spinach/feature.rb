module Spinach
  class Feature
    attr_accessor :filename
    attr_accessor :name, :scenarios, :tags
    attr_accessor :background
    attr_accessor :description
    attr_reader   :lines

    def initialize
      @scenarios = []
      @tags      = []
      @lines     = []
    end

    def background_steps
      @background.nil? ? [] : @background.steps
    end

    def lines=(value)
      @lines = value.map(&:to_i) if value
    end

    def only_run_scenarios_on_lines(lines)
      self.lines = lines.map(&:to_i)
    end

    def run_every_scenario?
      lines.empty?
    end

    # Run the provided code for every step
    def each_step
      scenarios.each { |scenario| scenario.steps.each { |step| yield step } }
    end
  end
end
