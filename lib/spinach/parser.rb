require 'gherkin_ruby'
require_relative 'parser/visitor'

module Spinach
  # Parser leverages GherkinRuby to parse the feature definition.
  #
  class Parser
    # @param [String] content
    #   The content to parse.
    #
    # @api public
    def initialize(content)
      @content = content
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

    # Parses the feature file and returns a Feature.
    #
    # @return [Feature]
    #   The Feature.
    #
    # @api public
    def parse
      ast = GherkinRuby.parse(@content + "\n")
      Visitor.new.visit(ast)
    end
  end
end
