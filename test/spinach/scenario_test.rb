require 'test_helper'

module Spinach
  describe Scenario do
    describe "#ordering_id" do
      let(:feature) { Feature.new }

      subject { Scenario.new(feature) }

      before do
        feature.filename = "features/foo/bar.feature"
        subject.lines    = Array(4..12)
      end

      it 'is the filename and starting line number' do
        subject.ordering_id.must_equal "features/foo/bar.feature:4"
      end
    end
  end
end
