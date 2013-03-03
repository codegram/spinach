require_relative '../../test_helper'
require_relative '../../../lib/spinach/generators'

module Spinach::Generators
  describe FeatureGenerator do
    subject do
      FeatureGenerator.new(feature)
    end

    let(:feature) do
      Spinach::Parser.new("""
Feature: Cheezburger can I has
  Background:
    Given I liek cheezburger
  Scenario: Some Lulz
    Given I haz a sad
    When I get some lulz
    Then I haz a happy
  Scenario: Some sad
    Given I haz a happy
    When I get some lulz
    Then I am OMG ROFLMAO""").parse
    end

    describe "#name" do
      it "returns the feature name" do
        subject.name.must_equal 'Cheezburger can I has'
      end
    end

    describe "#steps" do
      it "returns a correct number different steps for this data" do
        subject.steps.length.must_equal 5
      end
    end

    describe "#generate" do
      it "generates an entire feature_steps class definition" do
        result = subject.generate
        result.must_match(/step 'I haz a sad' do/)
        result.must_match(/pending 'step not implemented'/)
      end

      it 'scopes the generated class to prevent conflicts' do
        result = subject.generate
        result.must_match(/class Spinach::Features::CheezburgerCanIHas < Spinach::FeatureSteps/)
      end
    end

    describe "#filename" do
      it "returns a valid filename for the feature" do
        subject.filename.must_equal "cheezburger_can_i_has.rb"
      end
    end

    describe "#path" do
      it "should return a valid path" do
        subject.path.must_include 'features/steps'
      end
    end

    describe "#filename_with_path" do
      it "should the filename prepended with the path" do
        subject.filename_with_path.
          must_include 'features/steps/cheezburger_can_i_has.rb'
      end
    end

    describe "#store" do
      it "stores the generated feature into a file" do
        in_current_dir do
          subject.store
          File.directory?("features/steps/").must_equal true
          File.exists?("features/steps/cheezburger_can_i_has.rb").must_equal true
          File.read("features/steps/cheezburger_can_i_has.rb").strip.must_equal(
            subject.generate.strip
          )
          FileUtils.rm_rf("features/steps")
        end
      end

      it "raises an error if the file already exists and does nothing" do
        file = "features/steps/cheezburger_can_i_has.rb"
        in_current_dir do
          FileUtils.mkdir_p "features/steps"

          File.open(file, 'w') do |f|
            f.write("Fake content")
          end

          Proc.new{subject.store}.must_raise(
            Spinach::Generators::FeatureGeneratorException)

          FileUtils.rm_rf("features/steps")
        end
      end
    end
  end
end
