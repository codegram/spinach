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
    %w{When Given Then And But}.each do |connector|
      define_method connector do |string, &block|
        define_method("#{connector} #{string}", &block)
      end
    end

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
