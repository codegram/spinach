module Spinach
  # This class represents the feature raised when Spniach can't find a class
  # for a feature.
  class FeatureNotFoundException < StandardError
    def initialize(options)
      @not_found_class = options.first
      @feature = options.last
    end

    def message
      "Could not find class for `#{@feature}` feature. Please create a #{@not_found_class}.rb file at feature/steps"
    end
  end
end
