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

    # Execute a passed step from runner and returns step response or raises an
    # Exception if something goes wrong
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
