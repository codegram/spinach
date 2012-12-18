require_relative '../../test_helper'
require_relative '../../../lib/spinach/generators'

module Spinach::Generators
  describe StepGenerator do
    subject do
      StepGenerator.new(step)
    end

    let(:step) do
      stub(keyword: 'Given', name: 'I has a sad')
    end

    describe "#generate" do
      it "generates a step" do
        subject.generate.must_match /step.*I has a sad/
      end

      it "generates a pending step" do
        subject.generate.must_include "pending 'step not implemented'"
      end
    end

  end
end
