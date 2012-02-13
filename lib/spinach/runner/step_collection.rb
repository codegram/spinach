module Spinach
  class Runner
    class StepCollection
      def initialize(steps, context)
        @steps = steps.map do |step|
          StepRunner.new(step, context)
        end
      end

      def run
        previous_step_success = true
        @steps.each do |step|
          step.run(previous_step_success)
          previous_step_success = step.success?
        end
      end

      def success?
        @steps.all? do |step|
          step.success?
        end
      end
    end
  end
end
