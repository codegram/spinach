module Spinach
  # A step generator generates an example output for a step given the parsed
  # feature data.
  #
  class Generators::StepGenerator

    # @param [Step] step
    #   The step.
    def initialize(step)
      @step = step
    end

    # @return [String]
    #   an example step definition
    def generate
      result = StringIO.new
      result.puts "step '#{Spinach::Support.escape_single_commas @step.name}' do"
      result.puts "  pending 'step not implemented'"
      result.puts "end"
      result.string
    end
  end
end
