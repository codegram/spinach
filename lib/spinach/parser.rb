require 'gherkin'
require 'gherkin/formatter/json_formatter'

module Spinach
  class Parser
    def initialize(filename)
      @filename = filename
      @formatter = Gherkin::Formatter::JSONFormatter.new(nil)
      @parser = Gherkin::Parser::Parser.new(@formatter)
      @file = File.read(@filename)
    end

    def parse
      @parser.parse(@file, @filename, __LINE__-1)
      @formatter.gherkin_object
    end
  end
end
