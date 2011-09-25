module Spinach
  # Spinach's runner gets the parsed data from the feature and performs the
  # actual calls to the feature classes.
  #
  class Runner
    # Initializes the runner with a parsed feature
    # @param [Hash] data
    #   the parsed feature data
    #
    def initialize(data)
      @feature_name = data['name']
      @scenarios = data['elements']
      @reporter = Spinach::config.default_reporter.new
    end

    # The default reporter associated to this run
    attr_reader :reporter

    # Returns the feature class for the provided feature data
    # @return [Spinach::Feature] feature
    #   this runner's feature
    #
    def feature
      @feature ||= Spinach.find_feature(@feature_name).new
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
      step_count = 0
      reports = []

      reporter.feature(@feature_name)

      scenarios.each do |scenario|
        reporter.scenario(scenario['name'])
        scenario['steps'].each do |step|
          begin
            step_name = "#{step['keyword'].strip} #{step['name']}"
            feature.send(step_name)
            reporter.step(step_name, :success)
          rescue MiniTest::Assertion=>e
            reporter.step(step_name, :failure)
          end
        end
      end

      reporter.end

    end

  end
end
