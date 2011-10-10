module Spinach
  class Generators::StepGenerator
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def generate
      result = StringIO.new
      result.puts "#{data['keyword']} '#{escape data['name']}' do"
      result.puts "end"
      result.string
    end

    def escape(text)
      text.sub("'", "\\\\'")
    end
  end
end
