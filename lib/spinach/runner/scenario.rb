module Spinach
  class Runner
    class Scenario
      attr_reader :name, :steps

      def initialize(runner, data)
        @name = data['name']
        @steps = data['steps']
        @runner = runner
      end

      def reporter; @runner.reporter; end;

      def feature
        @feature ||= @runner.feature.new
      end

      def run
        reporter.scenario(name)
        feature.send(:before)
        steps.each do |step|
          step_name = "#{step['keyword'].strip} #{step['name']}"
          unless @failed
            @failed = true
            begin
              feature.execute_step(step_name)
              reporter.step(step_name, :success)
              @failed = false
            rescue MiniTest::Assertion => e
              reporter.step(step_name, :failure)
            rescue Spinach::StepNotDefinedException => e
              reporter.step(step_name, :undefined_step)
            rescue StandardError => e
              reporter.step(step_name, :error)
            end
          else
            reporter.step(step_name, :skip)
          end
        end
        feature.send(:after)
      end
    end
  end
end
