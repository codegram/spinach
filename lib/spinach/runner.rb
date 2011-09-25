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
    end

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
      step_count = 0
      reports = []

      scenarios.each do |scenario|
        instance = feature.new
        scenario['steps'].each do |step|
          begin
            instance.send(step['name'])
            print "\e[32m."
          rescue MiniTest::Assertion=>e
            reports << e
            print "\e[31mF"
          end
        end
      end

      print "\e[0m\n"
      puts
      reports.each do |report|
        puts "* #{report.message}\n\t"
        puts report.backtrace.reverse.join("\n")
      end
    end

  end
end
