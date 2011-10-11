require_relative '../test_helper'

describe Spinach::Generators do
  subject do
    Spinach::Generators
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

  describe "#bind" do
    it "binds the generator to the missing feature hook" do
      subject.expects(:generate_feature).with(data)
      subject.bind
      Spinach::Runner::FeatureRunner.new(stub_everything).run_hook :when_not_found, data
      Spinach::Runner::FeatureRunner._when_not_found_callbacks = []
    end
  end

  describe "#generate_feature" do
    it "generates a file" do
      feature_data = data
      FakeFS.activate!
      subject.generate_feature(feature_data)
      File.exists?("features/steps/cheezburger_can_i_has.rb").must_equal true
      FileUtils.rm_rf("features/steps")
      FakeFS.deactivate!
    end
    it "outputs a message if feature cannot be generated" do
      subject::FeatureGenerator.expects(:new).raises(
        Spinach::Generators::FeatureGeneratorException.new("File already exists"))
      capture_stdout do
        subject.generate_feature(data)
      end.must_include "File already exists"
      File.exists?("features/steps/cheezburger_can_i_has.rb").must_equal false
    end
  end
end
