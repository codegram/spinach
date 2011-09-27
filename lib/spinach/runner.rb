module Spinach
  # Spinach's runner gets the parsed data from the feature and performs the
  # actual calls to the feature classes.
  #
  class Runner
    # Initializes the runner with a parsed feature
    # @param [Hash] data
    #   the parsed feature data
    #
    def initialize(data, options = {})
      @feature_name = data['name']
      @scenarios = data['elements']

      @step_definitions_path = options.delete(:step_definitions_path ) ||
        Spinach.config.step_definitions_path

      @support_path = options.delete(:support_path ) ||
        Spinach.config.support_path

      @reporter = Spinach::config.default_reporter
    end

    # The default reporter associated to this run
    attr_reader :reporter

    # The default path where the steps are located
    attr_reader :step_definitions_path

    # The default path where the support files are located
    attr_reader :support_path

    # Returns the feature class for the provided feature data
    # @return [Spinach::Feature] feature
    #   this runner's feature
    #
    def feature
      @feature ||= Spinach.find_feature(@feature_name)
    end

    # @return [Hash]
    #   the parsed scenarios for this runner's feature
    #
    def scenarios
      @scenarios
    end

    # Runs this runner and outputs the results in a colorful manner.
    #
    def run
      require_steps

      step_count = 0
      reports = []

      reporter.feature(@feature_name)

      scenarios.each do |scenario|
        Scenario.new(self, scenario).run
      end
      reporter.end

    end

    def require_steps
      Dir.glob(
        File.expand_path File.join(step_definitions_path, '**', '*.rb')
      ).each do |file|
        require file
      end
    end
    private :require_steps

    def require_support
      Dir.glob(
        File.expand_path File.join(support_path, '**', '*.rb')
      ).each do |file|
        require file
      end
    end
    private :require_steps

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
            begin
              feature.send(step_name)
              reporter.step(step_name, :success)
            rescue MiniTest::Assertion=>e
              reporter.step(step_name, :failure)
              @failed = true
            rescue NoMethodError
              reporter.step(step_name, :undefined_step)
              @failed = true
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
