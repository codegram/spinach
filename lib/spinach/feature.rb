module Spinach
  class Feature
    attr_accessor :filename
    attr_accessor :name, :scenarios, :tags
    attr_accessor :background
    attr_accessor :description
    attr_reader   :lines_to_run

    def initialize
      @scenarios    = []
      @tags         = []
      @lines_to_run = []
    end

    def background_steps
      @background.nil? ? [] : @background.steps
    end

    def lines_to_run=(lines)
      @lines_to_run = lines.map(&:to_i) if lines && lines.any?
    end

    def run_every_scenario?
      lines_to_run.empty?
    end

    # Run the provided code for every step
    def each_step
      scenarios.each { |scenario| scenario.steps.each { |step| yield step } }
    end
  end
end
