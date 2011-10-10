require_relative '../../test_helper'
require_relative '../../../lib/spinach/generators'

module Spinach::Generators
  describe FeatureGenerator do
    subject do
      FeatureGenerator.new(data)
    end
    let(:data) do
      Spinach::Parser.new("
                          Feature: Funky stuff
                            Scenario: Some Lulz
                              Given I haz a sad
                              When I get some lulz
                              Then I has a happy
                            Scenario: Some sad
                              Given I haz a happy
                              When I get some lulz
                              Then I am OMG ROFLMAO
                          ").parse
    end
    describe "#steps" do
      it "returns the different steps for this data" do
      end
    end
  end
end
