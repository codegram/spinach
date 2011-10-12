require_relative '../../test_helper'
require_relative '../../../lib/spinach/generators'

module Spinach::Generators
  describe FeatureGenerator do
    subject do
      FeatureGenerator.new(data)
    end

    let(:data) do
      Spinach::Parser.new("
        Feature: Cheezburger can I has
          Scenario: Some Lulz
            Given I haz a sad
            When I get some lulz
            Then I haz a happy
          Scenario: Some sad
            Given I haz a happy
            When I get some lulz
            Then I am OMG ROFLMAO").parse
    end

    describe "#name" do
      it "returns the scenario name" do
        subject.name.must_equal 'Cheezburger can I has'
      end

      it "returns nil if no name present" do
        data['name'] = nil
        subject.name.must_equal nil
      end
    end

    describe "#steps" do
      it "returns a correct number different steps for this data" do
        subject.steps.length.must_equal 4
      end

      describe "includes the correct steps" do
        it "includes 'Given I haz a sad'" do
          subject.steps.any?{ |step|
            (step['keyword'] == 'Given') && (step['name'] == 'I haz a sad')
          }.must_equal true
        end

        it "includes 'When I get some lulz'" do
          subject.steps.any?{ |step|
            (step['keyword'] == 'When') && (step['name'] == 'I get some lulz')
          }.must_equal true
        end

        it "includes 'Then I has a happy'" do
          subject.steps.any?{ |step|
            (step['keyword'] == 'Then') && (step['name'] == 'I haz a happy')
          }.must_equal true
        end

        it "does not include 'Given I haz a happy'" do
          subject.steps.any?{ |step|
            (step['keyword'] == 'Given') && (step['name'] == 'I haz a happy')
          }.must_equal false
        end

        it "includes 'Then I am OMG ROFLMAO'" do
          subject.steps.any?{ |step|
            (step['keyword'] == 'Then') && (step['name'] == 'I am OMG ROFLMAO')
          }.must_equal true
        end
      end
    end

    describe "#generate" do
      it "generates an entire feature_steps class definition" do
        result = subject.generate
        klass = eval(result)
        feature_runner = Spinach::Runner::FeatureRunner.new(stub_everything)
        feature_runner.stubs(data: data)
        feature_runner.run.must_equal true
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
        FakeFS.activate!
        subject.store
        File.directory?("features/steps/").must_equal true
        File.exists?("features/steps/cheezburger_can_i_has.rb").must_equal true
        File.read("features/steps/cheezburger_can_i_has.rb").strip.must_equal(
          subject.generate.strip
        )
        FileUtils.rm_rf("features/steps")
        FakeFS.deactivate!
      end

      it "raises an error if the file already exists and does nothing" do
        file = "features/steps/cheezburger_can_i_has.rb"
        FakeFS.activate!
        FileUtils.mkdir_p "features/steps"
        File.open(file, 'w') do |f|
          f.write("Fake content")
        end
        Proc.new{subject.store}.must_raise(
          Spinach::Generators::FeatureGeneratorException)
        FileUtils.rm_rf("features/steps")
        FakeFS.deactivate!
      end
    end
  end
end
