require 'gherkin'
require 'gherkin/formatter/json_formatter'

module Spinach
  # Parser leverages Gherkin to parse the feature definition.
  #
  class Parser
    # @param [String] filename
    #   The filename to parse.
    #
    # @api public
    def initialize(filename)
      @filename = filename
      @formatter = Gherkin::Formatter::JSONFormatter.new(nil)
      @parser = Gherkin::Parser::Parser.new(@formatter)
    end

    # Gets the plain text content out of the feature file.
    #
    # @return [String]
    #   The plain feature content.
    #
    # @api public
    def content
      File.read(@filename)
    end

    # Parses the feature file and returns an AST as a Hash.
    #
    # @return [Hash]
    #   The parsed Gherkin output.
    #
    # @api public
    def parse
      @parser.parse(content, @filename, __LINE__-1)
      @formatter.gherkin_object
    end
  end
end
