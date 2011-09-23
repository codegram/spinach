module Spinach
  module DSL
    def When(string, &block)
      define_method(string, &block)
    end
    alias_method :Given, :When
    alias_method :Then, :When
    alias_method :And, :When
    alias_method :But, :When

    def feature(name)
      @feature_name = name
    end

    def feature_name
      @feature_name
    end
  end
end
