require 'minitest/spec'
MiniTest::Spec.new nil

module Spinach
  # The feature class is the class where all the features must inherit from.
  #
  class Feature
    extend DSL
    include MiniTest::Assertions

    def before; end;
    def after; end;

    def self.inherited(base)
      Spinach.features << base
    end

    # Execute a given step.
    #
    # @param [String] keyword
    #   the connector keyword. It usually is "Given", "Then", "When", "And"
    #   or "But"
    #
    # @param [String] step
    #   the step to execute
    #
    def execute_step(keyword, step)
      method = "#{keyword} #{step}"
      if self.respond_to?(method)
        self.send(method)
      else
        raise Spinach::StepNotDefinedException.new
      end
    end
  end
end
