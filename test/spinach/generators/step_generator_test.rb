require_relative '../../test_helper'
require_relative '../../../lib/spinach/generators'

module Spinach::Generators
  describe StepGenerator do
    subject do
      StepGenerator.new(data)
    end

    let(:data) do
      {'keyword' => 'Given', 'name' => "I has a sad"}
    end

    describe "#generate" do
      it "generates a step" do
        subject.generate.must_match /Given.*I has a sad/
      end
    end

    describe "#escape" do
      it "escapes the name" do
        subject.escape(
          "I've been doing bad things"
        ).must_include "I\\'ve been doing bad things"
      end
    end
  end
end
