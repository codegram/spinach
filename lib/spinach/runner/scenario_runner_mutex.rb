module Spinach
  class Runner
    class ScenarioRunnerMutex
      def initialize
        @running = false
      end

      def deactivate
        @running = false
      end

      def activate
        @running = true
      end

      def active?
        !!@running
      end
    end
  end
end
