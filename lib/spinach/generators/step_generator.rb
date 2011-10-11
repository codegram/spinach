module Spinach
  class Generators::StepGenerator
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def generate
      result = StringIO.new
      result.puts "#{data['keyword']} '#{Spinach::Support.escape data['name']}' do"
      result.puts "end"
      result.string
    end
  end
end
