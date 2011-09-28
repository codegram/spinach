module Spinach
  class Runner
    class Scenario
      attr_reader :name, :feature, :steps, :reporter

      def initialize(feature, data, reporter)
        @name = data['name']
        @steps = data['steps']
        @reporter = reporter
        @feature = feature
      end

      def run
        reporter.scenario(name)
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
      end
    end
  end
end
