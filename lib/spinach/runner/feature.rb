module Spinach
  class Runner
    class Feature
      def initialize(filename, reporter)
        @filename = filename
        @reporter = reporter
      end

      attr_reader :reporter

      attr_reader :filename

      def feature
        @feature ||= Spinach.find_feature(feature_name).new
      end

      def data
        @data ||= Spinach::Parser.new(filename).parse
      end

      def feature_name
        @feature_name ||= data['name']
      end

      # @return [Hash]
      #   the parsed scenarios for this runner's feature
      #
      def scenarios
        @scenarios ||= data['elements']
      end

      def run
        reporter.feature(feature_name)
        scenarios.each do |scenario|
          feature.send(:before)
          Scenario.new(feature, scenario, reporter).run
          feature.send(:after)
        end
      end

    end
  end
end
