require 'gherkin'
require 'gherkin/formatter/json_formatter'

module Spinach
  # Parser leverages Gherkin to parse the feature definition.
  #
  class Parser
    # @param [String] content
    #   The content to parse.
    #
    # @api public
    def initialize(content)
      @content = content
      @formatter = Gherkin::Formatter::JSONFormatter.new(nil)
      @parser = Gherkin::Parser::Parser.new(@formatter)
    end

    # @param [String] filename
    #   The filename to parse.
    #
    # @api public
    def self.open_file(filename)
      new File.read(filename)
    end

    # Gets the plain text content out of the feature file.
    #
    # @return [String]
    #   The plain feature content.
    #
    # @api public
    attr_reader :content

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
