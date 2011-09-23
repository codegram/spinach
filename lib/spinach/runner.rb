module Spinach
  class Runner
    def run(data)
      klass = Spinach.find_feature(data['name'])

      step_count = 0
      reports = []

      data['elements'].each do |element|
        instance = klass.new
        element['steps'].each do |step|
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
