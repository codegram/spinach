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
          keyword = step['keyword'].strip
          name = step['name'].strip
          unless @failed
            @failed = true
            begin
              feature.execute_step(keyword, name)
              reporter.step(keyword, name, :success)
              @failed = false
            rescue MiniTest::Assertion => e
              reporter.step(keyword, name, :failure)
            rescue Spinach::StepNotDefinedException => e
              reporter.step(keyword, name, :undefined_step)
            rescue StandardError => e
              reporter.step(keyword, name, :error)
            end
          else
            reporter.step(keyword, name, :skip)
          end
        end
      end
    end
  end
end
