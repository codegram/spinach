module Spinach
  class Runner
    # A Scenario Runner handles a particular scenario run.
    #
    class Scenario
      attr_reader :name, :feature, :steps, :reporter

      # @param [Spinach::Feature] feature
      #   the feature that contains the steps
      #
      # @param [Hash] data
      #   the parsed feature data
      #
      # @param [Spinach::Reporter]
      #   the reporter
      #
      def initialize(feature, data, reporter)
        @name = data['name']
        @steps = data['steps']
        @reporter = reporter
        @feature = feature
      end

      # Runs this scenario and signals the reporter
      #
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
