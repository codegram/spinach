require 'gherkin'
require 'gherkin/formatter/json_formatter'

module Spinach
  # Spinach's parser uses Gherkin in the guts to extract all the information
  # needed from the plain feature definition.
  #
  class Parser

    # @param [String] filename
    #   the file to parse
    #
    def initialize(filename)
      @filename = filename
      @formatter = Gherkin::Formatter::JSONFormatter.new(nil)
      @parser = Gherkin::Parser::Parser.new(@formatter)
    end

    # Gets the plain text content of the feature file.
    # @return [String]
    #   the plain feature content
    #
    def content
      File.read(@filename)
    end

    # @return [Hash] the parsed gerkin output
    def parse
      @parser.parse(content, @filename, __LINE__-1)
      @formatter.gherkin_object
    end
  end
end
