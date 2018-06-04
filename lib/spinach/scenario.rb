module Spinach
  class Scenario
    attr_accessor :lines
    attr_accessor :name, :steps, :tags, :feature

    def initialize(feature)
      @feature = feature
      @steps   = []
      @tags    = []
      @lines   = []
    end

    # Identifier used by orderers.
    #
    # Needs to involve the relative file path and line number so that the
    # ordering a seed generates is stable across both runs and machines.
    #
    # @api public
    def ordering_id
      "#{feature.ordering_id}:#{lines.first}"
    end
  end
end
