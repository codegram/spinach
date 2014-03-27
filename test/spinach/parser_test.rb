require_relative '../test_helper'

describe Spinach::Parser do
  before do
    @contents = """
Feature: User authentication
  As a developer
  I expect some stuff
  So that I have it

  Scenario: User logs in
    Given I am on the front page
    When I fill in the login form and press 'login'
    Then I should be on my dashboard
"""
    @parser = Spinach::Parser.new(@contents)
  end

  let(:parsed) { @parser.parse }

  describe '#parse' do
    it 'parses the file' do
      GherkinRuby.expects(:parse).returns ast = stub
      Spinach::Parser::Visitor.stubs(:new).returns visitor = stub
      visitor.expects(:visit).with ast
      @parser.parse
    end

    it 'includes description text in the feature' do
      feature = @parser.parse
      feature.description.must_equal ['As a developer', 'I expect some stuff', 'So that I have it']
    end
  end

  describe '.open_file' do
    it 'reads the disk and returns the file content' do
      File.expects(:read).with('feature_definition.feature')
      @parser = Spinach::Parser.open_file(
        'feature_definition.feature')
    end
  end

end
