require_relative '../test_helper'

describe Spinach::Generators do
  subject do
    Spinach::Generators
  end

  describe "#generate_feature" do
    it "outputs a message if feature cannot be generated" do
      in_current_dir do
        FileUtils.mkdir_p "features/steps"

        File.open('features/steps/cheezburger_can_i_has.rb', 'w') do |f|
          f.write("Feature: Fake feature")
        end

        Spinach::Generators::FeatureGenerator.any_instance.expects(:store).raises(
          Spinach::Generators::FeatureGeneratorException.new("File already exists"))

        capture_stdout do
          subject.run(["features/steps/cheezburger_can_i_has.rb"])
        end.must_include "File already exists"

        FileUtils.rm_rf("features/steps")
      end
    end
  end
end
