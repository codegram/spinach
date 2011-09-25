module Spinach
  # Spinach DSL aims to provide an easy way to define steps and other domain
  # specific actions into your feature classes
  #
  module DSL

    # Defines an action to perform given a particular step literal.
    #
    # @param [String] step name
    #   The step literal
    # @param [Proc] block
    #   action to perform in that step
    #
    # @example
    #   class MyFeature << Spinach::Feature
    #     When "I go to the toilet" do
    #       @sittin_on_the_toilet.must_equal true
    #     end
    #   end
    #
    def When(string, &block)
      define_method(string, &block)
    end
    alias_method :Given, :When
    alias_method :Then, :When
    alias_method :And, :When
    alias_method :But, :When

    # Defines this feature's name
    #
    # @example
    #   class MyFeature < Spinach::Feature
    #     feature "Satisfy needs"
    #   end
    #
    def feature(name)
      @feature_name = name
    end

    # @return [String] this feature's name
    #
    def feature_name
      @feature_name
    end
  end
end
