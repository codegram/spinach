module Spinach
  class Runner
    def initialize(data)
      @feature_name = data['name']
      @scenarios = data['elements']
    end

    def feature
      @feature ||= Spinach.find_feature(@feature_name)
    end

    def scenarios
      @scenarios
    end

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
