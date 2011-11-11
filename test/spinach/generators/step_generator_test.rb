require_relative '../../test_helper'
require_relative '../../../lib/spinach/generators'

module Spinach::Generators
  describe StepGenerator do
    subject do
      StepGenerator.new(step)
    end

    let(:step) do
      stub(name: 'I has a sad')
    end

    describe "#generate" do
      it "generates a step" do
        subject.generate.must_match /Given.*I has a sad/
      end
    end

  end
end
