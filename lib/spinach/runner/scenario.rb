module Spinach
  class Runner
    # A Scenario Runner handles a particular scenario run.
    #
    class Scenario
      attr_reader :name, :feature, :feature_name, :steps, :reporter

      # @param [Spinach::Feature] feature
      #   the feature that contains the steps
      #
      # @param [Hash] data
      #   the parsed feature data
      #
      # @param [Spinach::Reporter]
      #   the reporter
      #
      def initialize(feature_name, feature, data, reporter)
        @feature_name = feature_name
        @name = data['name']
        @steps = data['steps']
        @reporter = reporter
        @feature = feature
      end

      # Runs this scenario and signals the reporter
      #
      def run
        reporter.scenario(name)
        feature.run_hook :before_scenario, name
        steps.each do |step|
          keyword = step['keyword'].strip
          name = step['name'].strip
          line = step['line']
          feature.run_hook :before_step, keyword, name
          unless @failure
            begin
              feature.execute_step(name)
              reporter.step(keyword, name, :success)
            rescue MiniTest::Assertion => e
              @failure = [e, name, line, self]
              reporter.step(keyword, name, :failure)
            rescue Spinach::StepNotDefinedException => e
              @failure = [e, name, line, self]
              reporter.step(keyword, name, :undefined_step)
            rescue StandardError => e
              @failure = [e, name, line, self]
              reporter.step(keyword, name, :error)
            end
          else
            reporter.step(keyword, name, :skip)
          end
          feature.run_hook :after_step, keyword, name
        end
        feature.run_hook :after_scenario, name
        @failure
      end
    end
  end
end
