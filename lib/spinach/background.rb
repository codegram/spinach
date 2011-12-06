module Spinach
  class Background
    attr_accessor :line
    attr_accessor :steps, :feature

    def initialize(feature)
      @feature = feature
      @steps   = []
    end
  end
end
