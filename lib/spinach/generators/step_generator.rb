module Spinach
  # A step generator generates an example output for a step given the parsed
  # feature data.
  #
  class Generators::StepGenerator

    # @param [Hash] data
    #   the parsed step data returned from the {Parser}
    def initialize(data)
      @data = data
    end

    # @return [String]
    #   an example step definition
    def generate
      result = StringIO.new
      result.puts "#{@data['keyword']} '#{Spinach::Support.escape_single_commas @data['name']}' do"
      result.puts "end"
      result.string
    end
  end
end
